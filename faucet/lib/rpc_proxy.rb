require 'rack/proxy'

class RpcProxy < Rack::Proxy

  def rewrite_env(env)
    puts "===== RpcProxy call ======"
    p env

    # request = Rack::Request.new(env)
    # if request.path =~ %r{^/prefix|^/other_prefix}
    #   # do nothing
    # else
    #   env["HTTP_HOST"] = "localhost:3000"
    # end
    env
  end
end
