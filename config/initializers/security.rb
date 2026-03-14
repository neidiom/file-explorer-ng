# frozen_string_literal: true

# Security configurations for the file explorer application
Rails.application.config.after_initialize do
  # Force SSL in production environment
  if Rails.env.production?
    config.force_ssl = ENV['FORCE_SSL'] != 'false'
  end

  # Additional security headers
  config.action_dispatch.default_headers.merge!(
    'X-Content-Type-Options' => 'nosniff',
    'X-Download-Options' => 'noopen',
    'X-XSS-Protection' => '1; mode=block',
    'X-Frame-Options' => 'SAMEORIGIN',
    'Referrer-Policy' => 'strict-origin-when-cross-origin'
  )

  # Content security policy for production
  if Rails.env.production?
    config.content_security_policy do |policy|
      policy.default_src :self
      policy.style_src :self
      policy.script_src :self
      policy.img_src :self
      policy.object_src :none
      policy.base_uri :self
      policy.connect_src(:self) do
        |uri| uri == URI.parse(root_url) unless root_url.nil?
      end
    end
  end
end
