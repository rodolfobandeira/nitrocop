'foo'.unpack('h*').first
      ^^^^^^^^^^^^^^^^^^ Style/UnpackFirst: Use `unpack1('h*')` instead of `unpack('h*').first`.

'foo'.unpack('h*')[0]
      ^^^^^^^^^^^^^^^ Style/UnpackFirst: Use `unpack1('h*')` instead of `unpack('h*')[0]`.

'foo'.unpack('h*').at(0)
      ^^^^^^^^^^^^^^^^^^ Style/UnpackFirst: Use `unpack1('h*')` instead of `unpack('h*').at(0)`.

OpenSSL::PKCS5.pbkdf2_hmac(
  mnemonic, salt, 2048, 64, OpenSSL::Digest::SHA512.new
).unpack('H*')[0]
  ^^^^^^^^^^^^^^^ Style/UnpackFirst: Use `unpack1('H*')` instead of `unpack('H*')[0]`.

OpenSSL::PKCS5.pbkdf2_hmac(
  password,
  salt,
  iterations,
  128,
  OpenSSL::Digest.new("SHA512")
).unpack("H*").first
  ^^^^^^^^^^^^^^^^^^ Style/UnpackFirst: Use `unpack1("H*")` instead of `unpack("H*").first`.
