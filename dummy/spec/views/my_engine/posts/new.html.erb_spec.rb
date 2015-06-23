require 'rails_helper'

module MyEngine
  RSpec.describe "/my_engine/posts/new", type: :view do
    before(:each) do
      assign(:post, Post.new(
        :title => "MyString",
        :body => "MyText"
      ))
    end

    it "renders new post form" do
      render

      assert_select "form[action=?][method=?]", my_engine.posts_path, "post" do

        assert_select "input#post_title[name=?]", "post[title]"

        assert_select "textarea#post_body[name=?]", "post[body]"
      end
    end
  end
end
