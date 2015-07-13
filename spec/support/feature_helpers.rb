module FeatureHelpers
  def sign_in(user)
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
  end

  def click_in_datepicker(locator, text_to_click_on)
    find(locator).click
    within '#ui-datepicker-div' do
      find('a', text: /^#{text_to_click_on}$/).click
    end
  end

  RSpec::Matchers.define :appear_before do |later_content|
    match do |earlier_content|
      page.body.index(earlier_content) < page.body.index(later_content)
    end
  end
end

RSpec.configure do |config|
  config.include FeatureHelpers, type: :feature
end
