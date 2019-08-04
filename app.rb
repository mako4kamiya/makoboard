###
#ライブラリの読み込み
##
require 'sinatra'
require 'sinatra/reloader'
require 'fileutils' #画像フォルダを扱います。
require 'sinatra/cookies' #クッキーを使います。
require 'pg' #PostgeSQLを使えるようにする。

###
#sinatraの設定
##
set :public_folder, 'public'
enable :sessions #セッションを使います

###
#DBの設定？
##
def db
    host = 'localhost'
    user = 'kamiyamasako' #自分のユーザー名を入れる
    password = ''
    dbname = 'makoboard'
    
    # PostgreSQL クライアントのインスタンスを生成
    PG::connect(
    :host => host,
    :user => user,
    :password => password,
    :dbname => dbname)
end
###
#ルーティン
##
get '/' do
    @posts = db.exec_params("SELECT * FROM posts")
    erb :index
end

get '/post' do #投稿画面
    erb :post
end

post '/post' do #post画面のフォームデータをDBに送る
    name = params[:name]
    email = params[:email]
    content = params[:content]
    db.exec("INSERT INTO posts(name, email, content) VALUES($1,$2,$3)",[name,email,content])
    redirect '/'
end

#↓↓出来なかったやつ
# post '/post' dogi
#     name = params[:name]
#     email = params[:email]
#     content = params[:content]
#     db.exec("INSERT INTO posts(name, email, content) VALUES(name,email,content)")
#     redirect '/'
# end
