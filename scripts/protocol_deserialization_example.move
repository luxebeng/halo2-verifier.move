script {
    use halo2_verifier::params;
    use std::option;
    use aptos_std::crypto_algebra;
    use std::bn254_algebra::{G1, FormatG1Uncompr, FormatG2Uncompr, G2, Fr};
    use halo2_verifier::protocol;
    use std::vector;
    use aptos_std::crypto_algebra::Element;
    use halo2_verifier::bn254_utils;

    const TESTING_G1: vector<u8> = x"01000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000";
    const TESTING_G2: vector<u8> = x"edf692d95cbdde46ddda5ef7d422436779445c5e66006a42761e1f12efde0018c212f3aeb785e49712e7a9353349aaf1255dfb31b7bf60723a480d9293938e19aa7dfa6601cce64c7bd3430c69e7d1e38f40cb8d8071ab4aeb6d8cdba55ec8125b9722d1dcdaac55f38eb37033314bbc95330c69ad999eec75f05f58d0890609";
    const TESTING_S_G2: vector<u8> = x"e4115200acc86e7670c83ded726335def098657fe8668323e9e41e6781b83b0a9d83b54bbb00215323ce6d7f9d7f331a286d7707d03f7dbdd3125c6163588d13ed1abbe32fb3f9c8817d1ae305b395f5ff1db05263b9879602dc18c92e73d916ee07a11fd87eaa69ae764c48f7d618d1d531a4956eed421efcf2491a99769a16";

    fun protocol_deserialization_example(_s: signer) {
        let params = params::new(
            option::destroy_some(crypto_algebra::deserialize<G1, FormatG1Uncompr>(&TESTING_G1)),
            option::destroy_some(crypto_algebra::deserialize<G2, FormatG2Uncompr>(&TESTING_G2)),
            option::destroy_some(crypto_algebra::deserialize<G2, FormatG2Uncompr>(&TESTING_S_G2))
        );
        // protocol of example vector-mul
        // generated by `cargo run --release --  --param-path params/challenge_0078-kzg_bn254_16.srs --verifier-module protocol_store --verifier-address 0xcfae5b6bd579e7aff4274aeca434bb500c024b89c139b545c6eeb27bfafea8c1  --publish-vk-func decode_protocol build-publish-vk-aptos-txn --example vector-mul -o vk_deployment`
        let protocol = protocol::from_bytes(vector[
            x"0f040b991d2f930e735f0028ac957fb7ab6707474ed4eedbfe4f7cbb391c6f07",
            x"baaa5c0c4c452e320267ee0a90b648c30821c86d8627359fcb32e13deb83ad02",
            x"8703f8f88dac3610100dfbe5bb52498335e94896d2268e0128976bb88e15ec1bd7e110682012410aaebe615ee56d487414c5cdf4edc3ea7c94c18898207f750438eb14dd26e292dc9e41920db4619a83a4b6c5691825d26cc4a33fb29ccd69499a8c64ea83540da5130cd2f098126287ba27fc2f51dd20bc9fc7fe5bdfb3dd51",
            x"00",
            x"10",
            x"01000000",
            x"03000000",
            x"0100000000000000",
            x"0100000000000000",
            x"000000",
            x""
        ],
            vector[
                x"00000000000100000000",
                x"00010000000100000000",
                x"00020000000100000000"
            ],
            vector[
                x"f4000000000100000000"
            ],
            vector[x"ff000000000100000000"],
            vector[
                x"f400000000",
                x"0000000000",
                x"0001000000",
                x"0002000000"
            ],
            vector[
                x"02000000000000f093f5e1439170b97948e833285d588181b64550b829a031e1724e64300200000002000000010000000300000001000000010000000000000000000000000000000000000000000000000000000000000003000000000000000100000001000000010000000300000001000000"
            ],
            vector[],
            vector[]
        );
        let proof = x"06661ff6e3bd260e8dc4f9096034eaf96782d3fed55ec7fbc5928d2a8de1dd5ce1563c6c4fbc544a0544f957202b6cdcfb0b2e203ba886694a19542d8f749c2d9d0fe09c16f5172e45e48f82f28679649c482ae4baacec0c4d5514711eb4aa255508673b9a378da619ab1d60b24a077e7d4489f19e8b6610542d92ff65bb8d6b5442ab04b452a5199776c980dafb6e6ef641b08ce72c0c1560256b552a2a0520ce48ece7c5dd11faa9945ef0cdaffe033d613b6ee01a9584338a37dc189b6954e0fb075b65df7afa31f16a23fdda32d53accf86e4ab33c64b9237f9c7717326717ecb8a5f8dcba798cb4706badbf1e2816921a2b14773e2421b18fb8e9e5004e23c79f2df17f131018a9b0043d6583779d740aa5df3da4076942d7e82e9f7a46b737c901814134214beda0ebb34a512dee5929153286f57c7dbab5e4ef738640d2f0b3401061c36c6eadb63c55aaa3357d0e593c6a7860f3a570c618a604871aa83767b4cb569b4cd16cb0ae0740cb6ebbcf6f18fd825430c1caaadb6805650d2cca4df11456e2853f2356b5307b523030a82b13582a0377076657bc1294492b5a6328fc5d9320b2c5ce1792d8b401e4382a1fdb0deadc5cdd447847d6b3b02b0bfd442c0c7db984d0d870967335e53f531b9139e6ec7df43f601a5258d3a016e94a45148d1cfd60395aa986e5c2c4bb8692aa57045c6f772829084bd69f65214f5434f2de996df3559d95f5048cd5a60349f00fa9c22310fc9970e23053f32d0717727826b697a042ae376557dfc4dd3830038888488e5a21d5ac7f9cf30025b912e075fa88e2ee505b178e122f63ee4c7219bd82d7fb80918f914f50b9e11cd89b4365123a7d8beb4529c371f102c03ca22a994e67ebd4ec2401703d33101d242d591ac833fc91c152aea87ae65d81d1c5d1bdd50901d2430dd3b38b1d4c0e091b929d16ded653eceb1de9ca6f3a53b0f8411906d48c796927e728003c81185015ceb7ca4f7fa5d8ef02f6864f1804b408261400ed716f0b05a33fead5e2233c0ca6d4c131ba8221d364ebaa9583375168c925e2fe9bbf98ff93fa2de3ec295d4f780f7df328d6012abcfa37ffe0f185bbe12e470e1ba71e663c581adab7129d8e7a313d1ca418b1f1d35d5dc9229a10bf3f7c560570f591da67f02194ac09332bd46942c8c4127ae6cc33bcef1515d1de2c84e46e1d12876cd44fbcb6c30f872e14bf0c7cfb3376603e2811898c5f9776b200f601fcc2de97fcd25e89c206c15744f748146054424611186f4e97485032fb74de6a770fd7489d3e89a7550092f1f97e9048a549c3f9ef2d618c002a5722c8a50f9f614a05284fd27a41771f828688983206e1c96c71db5544f0ece50eda4adfa3219355e1be504bf454f022f85eb36928354ef1c2a4d9cc891273f46f30c672342b81a76b1edf4571557d1c38326379583844110da99a079f256a8b8f5ab1b43ce7a03e12ddda4530a5ff61";
        let instances = vector[
            x"0600000000000000000000000000000000000000000000000000000000000000",
            x"0600000000000000000000000000000000000000000000000000000000000000",
            x"0600000000000000000000000000000000000000000000000000000000000000"
        ];
        let instances = vector::map_ref<vector<u8>, Element<Fr>>(&instances, |instance| {
            option::destroy_some( bn254_utils::deserialize_fr(instance))
        });
    }
}