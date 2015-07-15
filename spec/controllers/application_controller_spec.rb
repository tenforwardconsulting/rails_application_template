require 'rails_helper'

RSpec.describe ApplicationController do

  describe 'require_admin' do
    controller do
      before_action :require_admin
      def index; render text: ''; end
    end

    it 'renders correctly if the current user is an admin' do
      sign_in FactoryGirl.create :admin
      expect(controller).not_to receive :render_not_authorized
      get :index
    end

    it 'renders not authorized if the current user is not an admin' do
      sign_in FactoryGirl.create :user
      expect(controller).to receive :render_not_authorized
      get :index
    end
  end

  describe 'render_not_authorized' do
    controller do
      def index; render_not_authorized; end
    end

    context 'when there is a referrer' do
      before :each do
        sign_in FactoryGirl.create :user
        allow(controller.request).to receive(:referrer).and_return root_path
      end

      it "reports to rollbar that there was a link visible that shouldn't have been" do
        expect(Rollbar).to receive :error
        get :index
      end

      it 'redirects back to the referrer' do
        get :index
        expect(response).to redirect_to root_path
      end
    end

    context 'when there is not a signed in user' do
      it 'redirects to root_path' do
        get :index
        expect(response).to redirect_to root_path
      end
    end

    it 'redirects the user' do
      sign_in FactoryGirl.create :user
      get :index
      expect(response).to be_redirect
    end

    it 'sets an alert flash' do
      sign_in FactoryGirl.create :user
      get :index
      expect(flash[:alert]).to eq 'Not authorized'
    end
  end
end

