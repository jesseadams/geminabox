require 'sinatra/base'

class Hostess < Sinatra::Base
  def serve
    file = File.expand_path(File.join(Geminabox.data, *request.path_info))

    unless File.exists?(file)
      Net::HTTP.start("production.cf.rubygems.org") do |http|
        path = File.join(*request.path_info)
        puts path
        response = http.get(path)
        open(file, "wb") do |file|
          file.write(response.body)
        end
      end
    end

    send_file(File.expand_path(File.join(Geminabox.data, *request.path_info)), :type => response['Content-Type'])
  end

  %w[/specs.4.8.gz
     /latest_specs.4.8.gz
     /prerelease_specs.4.8.gz
  ].each do |index|
    get index do
      content_type('application/x-gzip')
      serve
    end
  end

  %w[/quick/Marshal.4.8/*.gemspec.rz
     /yaml.Z
     /Marshal.4.8.Z
  ].each do |deflated_index|
    get deflated_index do
      content_type('application/x-deflate')
      serve
    end
  end

  %w[/yaml
     /Marshal.4.8
     /specs.4.8
     /latest_specs.4.8
     /prerelease_specs.4.8
  ].each do |old_index|
    get old_index do
      serve
    end
  end

  get "/gems/*.gem" do
    serve
  end
end
