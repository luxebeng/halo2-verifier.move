module halo2_verifier::lookup {
    use halo2_verifier::transcript::Transcript;
    use halo2_verifier::transcript;
    use halo2_verifier::point::Point;
    use halo2_verifier::scalar::Scalar;

    struct PermutationCommitments has copy,drop {
        permuted_input_commitment: Point,
        permuted_table_commitment: Point,
    }

    struct Commited has copy,drop {
        permuted: PermutationCommitments,
        product_commitment: Point,
    }
    struct Evaluated has copy, drop {
        product_eval: Scalar,
        product_next_eval: Scalar,
        permuted_input_eval: Scalar,
        permuted_input_inv_eval: Scalar,
        permuted_table_eval: Scalar,
    }

    public fun read_permuted_commitments(transcript: &mut Transcript): PermutationCommitments {
        PermutationCommitments {
            permuted_input_commitment: transcript::read_point(transcript),
            permuted_table_commitment: transcript::read_point(transcript),
        }
    }

    public fun read_product_commitment(c: PermutationCommitments, transcript: &mut Transcript): Commited {
        Commited {
            permuted: c,
            product_commitment: transcript::read_point(transcript),
        }
    }
    public fun evaluate(_c: &Commited, transcript: &mut Transcript): Evaluated {
        let product_eval = transcript::read_scalar(transcript);
        let product_next_eval = transcript::read_scalar( transcript);
        let permuted_input_eval = transcript::read_scalar( transcript);
        let permuted_input_inv_eval = transcript::read_scalar( transcript);
        let permuted_table_eval = transcript::read_scalar( transcript);
        Evaluated {
            product_eval,
            product_next_eval,
            permuted_input_eval,
            permuted_input_inv_eval,
            permuted_table_eval
        }
    }
}