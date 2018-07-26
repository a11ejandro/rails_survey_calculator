#!/usr/bin/env ruby

require 'English'
require 'bundler'
require 'bundler/setup'
require 'pg'
require 'timeout'

class Entry
  def db_conn(options = {})
    settings = {
      host: ENV['POSTGRES_HOST'],
      port: ENV['POSTGRES_PORT'],
      user: ENV['POSTGRES_USERNAME'],
      password: ENV['POSTGRES_PASSWORD'],
      dbname: ENV['POSTGRES_DATABASE'],
      connect_timeout: 2
    }.merge(options)

    PG::Connection.new(settings)
  end

  def wait_for_db(wait_time = 30)
    sleep 5 # give database time to spin up

    Timeout.timeout(wait_time) do
      begin
        conn = db_conn(dbname: 'postgres')
        raise "[DB] Connection error." unless conn.status == PG::CONNECTION_OK

        puts "[DB] Connected!"
      rescue PG::ConnectionBad => e
        puts "[DB] Connection failed: #{e.message}"
        puts "[DB] Retrying..."
        sleep 2
        retry
      end
    end
  end

  def db_exists?(name)
    db_conn(dbname: name).status == PG::CONNECTION_OK
  rescue PG::ConnectionBad
    false
  end

  def init_db
    unless db_exists?(ENV['POSTGRES_DATABASE'])
      puts 'no database found'
      puts 'creating db...'
      run_command('rake', 'db:create')
    end

    run_command('rake', 'db:migrate')
  end

  def populate_db
    pg_result = db_conn.exec('SELECT COUNT(*) FROM survey_results')
    if pg_result.getvalue(0, 0).to_i < 10
      puts 'populating db...'
      run_command('rake', 'db:populate_survey_results')
    end
  end

  def call(*args)
    wait_for_db
    init_db
    populate_db
    Process.exec(*args)
  end

  def run_command(cmd, *args)
    system(cmd, *args) && return

    effective_cmd = [cmd, args].flatten.join(' ')
    raise "Command failed:\n\tCMD: #{effective_cmd}\n\tSTATUS: #{$CHILD_STATUS}"
  end
end

# MAIN
begin
  entry = Entry.new
  entry.call(*ARGV)
rescue StandardError => e
  puts "Entrypoint error:\n#{e.message}"
  Process.exit(1)
end
