/**
 * Copyright Soramitsu Co., Ltd. 2017 All Rights Reserved.
 * http://soramitsu.co.jp
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef IROHA_SHARED_MODEL_SIGNED_HPP
#define IROHA_SHARED_MODEL_SIGNED_HPP

#include "cryptography/blob.hpp"

#include "common/types.hpp"  // for iroha::sig_t

namespace shared_model {
  namespace crypto {
    /**
     * Class for storing signed data. It could be used not only for storing
     * signed hashes but for other signed objects too.
     */
    class Signed : public Blob {
     public:
      using OldSignatureType = iroha::sig_t;

      explicit Signed(const std::string &blob);

      std::string toString() const override;
    };
  }  // namespace crypto
}  // namespace shared_model

#endif  // IROHA_SHARED_MODEL_SIGNED_HPP
