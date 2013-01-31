# impala-herd

This is an example app to show off impala-ruby. It's a productivity tool that lets you run queries through the interface, save the results, and share them.

If you want to run it, you'll need an Impala server and a MongoDB server both running.

To set it up, first clone the repository. Then edit this section in `app.rb`:

    configure do
      set :impala_host, 'virtualbox'
      set :impala_port, 21000

      set :mongodb_host, 'localhost'
      set :mongodb_port, 27017
    end

to point to the right hosts/ports. Then just run `ruby app.rb`.