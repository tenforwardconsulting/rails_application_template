RSpec.configure do |config|
  config.before :each, timecop: :freeze do
    Timecop.freeze
  end

  config.after :each, timecop: :freeze do
    Timecop.return
  end
end
