require 'rails_helper'

module MyEngine
  RSpec.describe "/my_engine/posts/show", type: :view do
    before(:each) do
      @post = assign(:post, Post.create!(
        :title => "Title",
        :body => "MyText"
      ))
    end

    it "renders attributes in <p>" do
      render
      expect(rendered).to match(/Title/)
      expect(rendered).to match(/MyText/)
    end
  end
end
