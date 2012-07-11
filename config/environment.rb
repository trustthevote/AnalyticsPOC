# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
VoterLogAnalytics::Application.initialize!

# JVC tried this to get my local SMTP server working properly
ActionMailer::Base.smtp_settings[:enable_starttls_auto] = false
