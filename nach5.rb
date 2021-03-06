require 'sinatra'
require 'data_mapper'

enable :sessions

DataMapper::setup(:default, "sqlite://#{Dir.pwd}/natch5.db")

class Post
	include DataMapper::Resource
	property :id, Serial
	property :toplevel, Boolean
	property :content, Text, :required=>true
	property :imgurl, Text
	property :created_at, DateTime
	property :comments, Text # comma-separated list of serial id's of all replies to the post
	#@comments # contains serial id's of all replies to the post FIXME: bad way to do this
end

DataMapper.finalize.auto_upgrade!

# display main page
get '/' do
	@posts = Post.all :order => :id.desc
	@title = 'main page'
	erb :home
end

# when a post is submitted on the main page
post '/' do
	p = Post.new
	p.toplevel = true
	p.content = params[:content]
	p.imgurl = params[:imgurl]
	p.created_at = Time.now
	p.comments = ""
	p.save
	redirect '/'
end

# when viewing the page for a certain post
get '/post/:id' do
	@post = Post.get params[:id]
	@title = params[:id]
	erb :viewpost
end

# when you're writing a reply to a post
get '/post/:id/reply' do
	@post = Post.get params[:id]
	@title = "Reply to ##{params[:id]}"
	erb :reply
end

# when a reply is submitted to a post
post '/post/:id/reply' do
	@post = Post.get params[:id]
	p = Post.new
	p.toplevel = false
	p.content = params[:content]
	p.created_at = Time.now
	p.save
	@post.comments += ",#{p.id}"
	redirect '/post/:id'
end

not_found do
	status 404
	"404 nigger"
end
