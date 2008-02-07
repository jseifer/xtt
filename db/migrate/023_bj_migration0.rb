          class BjMigration0 < ActiveRecord::Migration
            def self.up
              create_table "bj_config", :primary_key => "bj_config_id", :force => true do |t|
                t.string "hostname"
                t.string "key"
                t.text "value"
                t.string "cast"
              end
              add_index :bj_config, %w(hostname key), :name => :index_bj_config_on_hostname_and_key
              
              create_table "bj_job", :primary_key => "bj_job_id", :force => true do |t|
                t.text     "command"
                t.string     "state"
                t.integer  "priority"
                t.string     "tag"
                t.integer  "is_restartable"
                t.text     "submitter"
                t.text     "runner"
                t.integer  "pid"
                t.datetime "submitted_at"
                t.datetime "started_at"
                t.datetime "finished_at"
                t.text     "env"
                t.text     "stdin"
                t.text     "stdout"
                t.text     "stderr"
                t.integer  "exit_status"
              end
              
              create_table "bj_job_archive", :primary_key => "bj_job_archive_id", :force => true do |t|
                t.text     "command"
                t.string     "state"
                t.integer  "priority"
                t.string     "tag"
                t.integer  "is_restartable"
                t.text     "submitter"
                t.text     "runner"
                t.integer  "pid"
                t.datetime "submitted_at"
                t.datetime "started_at"
                t.datetime "finished_at"
                t.datetime "archived_at"
                t.text     "env"
                t.text     "stdin"
                t.text     "stdout"
                t.text     "stderr"
                t.integer  "exit_status"
              end
            end
            def self.down
              Bj::Table.reverse_each{|table| table.down}
            end
          end
