Rails 4.2 + RSpecでMountableなEngineを作る
==========================================

Mountable Engineが何とかそういう話すっ飛ばして、ざっと作り方を見ていきたいと思います。

## 環境

* Ruby 2.2.2
* Rails 4.2.2
* RSpec 3.3.x

## エンジンを生成する

何はともあれエンジンを生成します。`rails plugin new`コマンドで生成できます。

```shell
$ rails plugin new -h
Usage:
  rails plugin new APP_PATH [options]

Options:
  -r, [--ruby=PATH]                                      # Path to the Ruby binary of your choice
                                                         # Default: /Users/iyuuya/.anyenv/envs/rbenv/versions/2.2.2/bin/ruby
  -m, [--template=TEMPLATE]                              # Path to some plugin template (can be a filesystem path or URL)
      [--skip-gemfile], [--no-skip-gemfile]              # Don't create a Gemfile
  -B, [--skip-bundle], [--no-skip-bundle]                # Don't run bundle install

(略)

Example:
    rails plugin new ~/Code/Ruby/blog

    This generates a skeletal Rails plugin in ~/Code/Ruby/blog.
    See the README in the newly created plugin to get going.
```

ドキュメントに従って生成してみます。
今回は`--no-rc`を付けていますが必要なければ外してください。

```shell
$ rails plugin new my_engine --mountable --skip-test-unit --dummy-path=dummy --no-rc
      create
      create  README.rdoc
      create  Rakefile
      create  my_engine.gemspec
      create  MIT-LICENSE
      create  .gitignore
      create  Gemfile
      create  app
      create  app/controllers/my_engine/application_controller.rb
      create  app/helpers/my_engine/application_helper.rb
      create  app/mailers
      create  app/models
      create  app/views/layouts/my_engine/application.html.erb
      create  app/assets/images/my_engine
      create  app/assets/images/my_engine/.keep
      create  config/routes.rb
      create  lib/my_engine.rb
      create  lib/tasks/my_engine_tasks.rake
      create  lib/my_engine/version.rb
      create  lib/my_engine/engine.rb
      create  app/assets/stylesheets/my_engine/application.css
      create  app/assets/javascripts/my_engine/application.js
      create  bin
      create  bin/rails
  vendor_app  spec
         run  bundle install
Fetching gem metadata from https://rubygems.org/...........
(略)
Use `bundle show [gemname]` to see where a bundled gem is installed.
```

生成できました。簡単。

## RSpecのインストール

RSpecをインストールします。
(色々意見はあるかもしれませんが)今回は`Gemfile`に記述します。

```Gemfile
source 'https://rubygems.org'

gemspec

group :development, :test do
  gem 'rspec-rails', '~> 3.3.2'
end
```

`rspec-rails`をインストールし、普段通り`rails_helper.rb`,`spec_helper.rb`を生成します。

```shell
bundle install
bin/rails g rspec:install
```

integration_toolが`:test_unit`になってしまうので、修正します。

```lib/my_engine/engine.rb
module MyEngine
  class Engine < ::Rails::Engine
    isolate_namespace MyEngine

    config.generators do |g|
      g.test_framework :rspec
      g.integration_tool :rspec
    end
  end
end
```

`vendor_app(dummy)`でspecを使うようにします。

```shell
mv ./.rspec ./dummy
mv ./spec ./dummy
ln -s ./dummy/spec ./spec
```

`spec/rails_helper.rb`を修正します。

```spec/rails_helper.rb
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../dummy/config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
...
```

### FactoryGirlのインストール

例によって`Gemfile`に追記します。

```Gemfile
group :development, :test do
  gem 'rspec-rails', '~> 3.3.2'
  gem 'factory_girl_rails
end
```

Engine開発時に気をつけないといけないのですが、このままだと`test`以下に`factory`が生成されてしまいます。

```shell
$ bin/rails g factory_girl:model hoge fuga:string
      create  test/factories/my_engine_hoges.rb
```

なので、generatorの設定を修正します。

```lib/my_engine/engine.rb
module MyEngine
  class Engine < ::Rails::Engine
    isolate_namespace MyEngine

    config.generators do |g|
      g.test_framework :rspec, fixtures: false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.integration_tool :rspec
    end
  end
end
```

```
$ bin/rails g factory_girl:model hoge fuga:string
      create  spec/factories/my_engine_hoges.rb
```

## CRUDを作ってみる

特に良いネタが思い浮かばなかったので、ひとまず記事の投稿ができるようにしてみます。

```shell
$ bin/rails g scaffold post title:string body:text
      invoke  active_record
      create    db/migrate/20150622175240_create_my_engine_posts.rb
      create    app/models/my_engine/post.rb
      invoke    rspec
      create      spec/models/my_engine/post_spec.rb
      invoke      factory_girl
      create        spec/factories/my_engine_posts.rb
      invoke  resource_route
       route    resources :posts
      invoke  scaffold_controller
(略)
      invoke  css
      create    app/assets/stylesheets/scaffold.css
```

... 

TODO
----

- [ ] ...
