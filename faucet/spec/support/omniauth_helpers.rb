OmniAuth.config.mock_auth[:twitter] =
    OmniAuth::AuthHash.new(
        {
            :provider => 'twitter',
            :uid => '123',
            :info => {
                'name' => 'Username',

            }
        })

OmniAuth.config.mock_auth[:linkedin] =
    OmniAuth::AuthHash.new(
        {
            :provider => 'linkedin',
            :uid => '123',
            :info => {
                'name' => 'Username',
                'email' => 'mail@mail.com'
            }
        })
