[ req ]
default_bits       = 4096
default_md         = sha512
default_keyfile    = %KEY%
prompt             = no
encrypt_key        = no

distinguished_name = req_distinguished_name

[ req_distinguished_name ]
countryName            = "UA"                     # C=
stateOrProvinceName    = "Kyiv"                   # ST=
localityName           = "Kyiv"                   # L=
postalCode             = "03134"                  # L/postalcode=
streetAddress          = "Kreschatyk"             # L/street=
organizationName       = "POL"                    # O=
organizationalUnitName = "IT Department"          # OU=
commonName             = "*.%HOST%"               # CN=
emailAddress           = "ukrolove@gmail.com"     # CN/emailAddress=
