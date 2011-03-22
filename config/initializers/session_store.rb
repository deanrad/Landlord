# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_landlord_rails2_session',
  :secret      => '99ddd50ac06995b7ce0724eee85ac9a49e019934c96a9846b7511918fdc617e8c16c21906d2733c66c26944e34d1cf05e02f6cb8c3131080dbd0cacbe1f4b721'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
