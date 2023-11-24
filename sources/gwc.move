module halo2_verifier::gwc {
    use std::vector;

    use aptos_std::crypto_algebra;

    use halo2_verifier::bn254_types::{G1, G2, Gt};
    use halo2_verifier::msm::{Self, MSM};
    use halo2_verifier::params::{Self, Params};
    use halo2_verifier::point;
    use halo2_verifier::query::{Self, VerifierQuery};
    use halo2_verifier::scalar::{Self, Scalar};
    use halo2_verifier::transcript::{Self, Transcript};

    public fun verify(
        params: &Params,
        transcript: &mut Transcript,
        queries: &vector<VerifierQuery>
    ): bool {
        let v = transcript::squeeze_challenge(transcript);
        let sets = construct_intermediate_sets(queries);
        let set_len = vector::length(&sets);
        let w = transcript::read_n_point(transcript, set_len);
        let u = transcript::squeeze_challenge(transcript);

        // commitment_multi = C(0)+ u * C(1) + u^2 * C(2) + .. + u^n * C(n)
        let commitment_multi = msm::empty_msm();
        // eval_multi = E(0)+ u * E(1) + u^2 * E(2) + .. + u^n * E(n)
        let eval_multi = scalar::zero();
        // witness = u^0 * w_0 + u^1 * w_1 + u^2 * w_2 + .. u^n * w_n
        let witness = msm::empty_msm();
        // witness_with_aux = u^0 * z_0 * w_0 + u^1 * z_1 * w_1 + u^2 * z_2 * w_2 + .. u^n * z_n * w_n
        let witness_with_aux = msm::empty_msm();


        let i = 0;
        let power_of_u = scalar::one();

        while (i < set_len) {
            let commitment_at_a_point = vector::borrow(&sets, i);
            let w_i = vector::borrow(&w, i);
            let z = query::point(vector::borrow(commitment_at_a_point, 0));

            // C(i) = sum_j(v^(j-1) * cm(j))
            let commitment_acc = msm::empty_msm();
            // E(i) = sum_j(v^(j-1) * s(j))
            let eval_acc = scalar::zero();
            {
                let j = 0;
                let query_len = vector::length(commitment_at_a_point);
                let power_of_v = scalar::one();
                while (j < query_len) {
                    let q = vector::borrow(commitment_at_a_point, j);
                    let c = query::multiply(query::commitment(q), &power_of_v);
                    let eval = scalar::mul(&power_of_v, query::eval(q));
                    msm::add_msm(&mut commitment_acc, &c);
                    eval_acc = scalar::add(&eval_acc, &eval);

                    power_of_v = scalar::mul(&power_of_v, &v);
                    j = j + 1;
                };
            };
            msm::scale(&mut commitment_acc, &power_of_u);
            msm::add_msm(&mut commitment_multi, &commitment_acc);
            eval_multi = scalar::add(&eval_multi, &scalar::mul(&power_of_u, &eval_acc));
            msm::append_term(&mut witness_with_aux, scalar::mul(&power_of_u, z), *w_i);
            msm::append_term(&mut witness, power_of_u, *w_i);

            power_of_u = scalar::mul(&power_of_u, &u);
            i = i + 1;
        };

        // then we verify:
        // e(witness, [x]@2) = e(commitment_multi + witness_with_aux - [eval_multi]@1, [1]@2)
        verify_inner(params, witness, commitment_multi, eval_multi, witness_with_aux)
    }

    // e(witness, [x]@2) = e(commitment_multi + witness_with_aux - [eval_multi]@1, [1]@2)
    fun verify_inner(
        params: &Params,
        witness: MSM,
        commitment_multi: MSM,
        eval_multi: Scalar,
        witness_with_aux: MSM
    ): bool {
        msm::add_msm(&mut commitment_multi, &witness_with_aux);
        msm::append_term(&mut commitment_multi, eval_multi, point::neg(params::g(params)));
        let right = msm::eval(&commitment_multi);
        let left = msm::eval(&witness);

        let left_pairing = crypto_algebra::pairing<G1, G2, Gt>(
            point::underlying(&left),
            point::underlying(params::s_g2(params))
        );
        let right_pairing = crypto_algebra::pairing<G1, G2, Gt>(
            point::underlying(&right),
            point::underlying(params::g2(params))
        );
        crypto_algebra::eq(&left_pairing, &right_pairing)
    }

    fun construct_intermediate_sets(queries: &vector<VerifierQuery>): vector<vector<VerifierQuery>> {
        let sets = vector::empty();
        let query_len = vector::length(queries);
        let i = 0;
        while (i < query_len) {
            let q = vector::borrow(queries, i);
            let point = query::point(q);
            let (find, index) = vector::find(&sets, |s| {
                let s: &vector<VerifierQuery> = s;
                query::point(vector::borrow(s, 0)) == point
            });
            if (find) {
                vector::push_back(vector::borrow_mut(&mut sets, index), *q);
            } else {
                vector::push_back(&mut sets, vector::singleton(*q));
            };

            i = i + 1;
        };
        sets
    }
}
