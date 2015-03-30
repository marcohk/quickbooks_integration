require_relative 'lib/qb_integration'

if File.exists? File.join(File.expand_path(File.dirname(__FILE__)), '.env')
  # TODO check an ENV variable i.e. RACK_ENV
  begin
    require 'dotenv'
    Dotenv.load
  rescue => e
    puts e.message
    puts e.backtrace.join("\n")
  end
end

class QuickbooksEndpoint < EndpointBase::Sinatra::Base
  set :logging, true

  Honeybadger.configure do |config|
    config.api_key          = ENV['HONEYBADGER_KEY']
    config.environment_name = ENV['RACK_ENV']
  end

  set :show_exceptions, false

  error do
    result 500, lookup_error_message
  end

  post '/add_product' do
    format_hash!(@payload)

    code, summary = QBIntegration::Product.new(@payload, @config).import
    result code, summary
  end

  post '/update_product' do
    format_hash!(@payload)

    code, summary = QBIntegration::Product.new(@payload, @config).import
    result code, summary
  end

  post '/add_order' do
    format_hash!(@payload)

    begin
      code, summary = QBIntegration::Order.new(@payload, @config).create
      result code, summary
    rescue QBIntegration::AlreadyPersistedOrderException => e
      result 500, e.message
    end
  end

  post '/update_order' do
    format_hash!(@payload)

    code, summary = QBIntegration::Order.new(@payload, @config).update
    result code, summary
  end

  post '/cancel_order' do
    format_hash!(@payload)

    code, summary = QBIntegration::Order.new(@payload, @config).cancel
    result code, summary
  end

  post '/add_return' do
    format_hash!(@payload)

    code, summary = QBIntegration::ReturnAuthorization.new(@payload, @config).create
    result code, summary
  end

  post '/update_return' do
    format_hash!(@payload)

    code, summary = QBIntegration::ReturnAuthorization.new(@payload, @config).update
    result code, summary
  end

  post '/get_inventory' do
    stock = QBIntegration::Stock.new(@payload, @config)

    if stock.name.present? && stock.item
      add_object :inventory, stock.inventory
      result 200
    elsif stock.items.present?
      stock.inventories.each { |item| add_object :inventory, item }
      add_parameter 'quickbooks_poll_stock_timestamp', stock.last_modified_date
      result 200
    else
      result 200
    end
  end

  def lookup_error_message
    case env['sinatra.error'].class.to_s
    when "Quickbooks::AuthorizationFailure"
      "Authorization failure. Please check your Quickbooks credentials"
    when "Quickbooks::ServiceUnavailable"
      "Quickbooks API appears to be inaccessible HTTP 503 returned."
    else
      env['sinatra.error'].message
    end
  end

  def format_hash!(hash)
    hash.each do |key, value|
      value.is_a?(Hash) ? format_hash!(value) :
      value.is_a?(Array) ? value.each do |item| format_hash!(item) end :
      value.is_a?(String) ? hash[key] = value.gsub(/([0-9a-f]{8})-([0-9a-f]{4})-([0-9a-f]{4})-([0-9a-f]{4})-([0-9a-f]{12})/, '\1\2\3\4'):
      nil
    end
  end

end
