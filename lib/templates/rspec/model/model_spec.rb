require 'rails_helper'

<% module_namespacing do -%>
RSpec.describe <%= class_name %> do

  describe 'factory' do
    it 'creates valid <%= snake_case_class_name = class_name.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase %>' do
      expect(FactoryGirl.create :<%= snake_case_class_name %>).to be_valid
    end
  end

  describe 'validations' do
  end
end
<% end -%>
