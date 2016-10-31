require 'spec_helper'

describe Api::FavoritesController, :type => :controller do
  before do
    request.env["HTTP_ACCEPT"] = 'application/json'
    @user     = create(:user)
    @tripnote = create(:tripnote)
  end

  let(:valid_session) { { user_id: @user.id } }

  describe 'POST /api/favorites' do
    let(:valid_attributes) { { favorite: { tripnote_id: @tripnote.id } } }

    it "should NOT success for invalid params" do
      post :create, { favorite: { tripnote_id: "" } }, valid_session
      expect(response).not_to be_success
    end

    it "should success for valid params" do
      post :create, valid_attributes, valid_session
      expect(response.status).to eq(201)
    end

    it "create Favorite" do
      expect {
        post :create, valid_attributes, valid_session
      }.to change(Favorite, :count).by(1)
    end

    it "should NOT success for twice fav" do
      post :create, { favorite: { tripnote_id: @tripnote.id } }, valid_session
      expect(response.status).to eq(201)
      post :create, { favorite: { tripnote_id: @tripnote.id } }, valid_session
      expect(response).not_to be_success
    end

  end

  describe 'DELETE /api/favorites/:id' do
    before do
      @favorite = create(:favorite, user: @user, tripnote: @tripnote)
    end

    it "should success for valid id" do
      delete :destroy, { id: @favorite.id }, valid_session
      expect(response).to be_success
    end

    it "should fail for empty id" do
      delete :destroy, { id: "" }, valid_session
      expect(response.status).to eq(404)
    end

    it "should fail for not existing id" do
      delete :destroy, { id: "0" }, valid_session
      expect(response.status).to eq(404)
    end

    it "should fail for not own fav" do
      delete :destroy, { id: @favorite.id + 1 }, valid_session
      expect(response).not_to be_success
    end
  end
end

