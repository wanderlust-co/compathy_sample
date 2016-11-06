ENV=development
SAMPLE_ONLY=true
DBUSER=compathy
DBPASS=compathypass
DBHOST=localhost
DBNAME=compathy2_development
UNICORN=unicorn_compathy
MAINT_DATE=20150101

usage:
	@echo "USAGE:"
	@echo "  make init"
	@echo "  make init_db"
	@echo "  make reset_db"
	@echo "  make reset_testdb"
	@echo "  make reset_redis_development"
	@echo "  make bundle"
	@echo "  make deploy ENV=staging"
	@echo "  make deploy_cron_production"
	@echo "  make clear_cache_top"
	@echo "  make clear_rails_cache"
	@echo "  make sitemap_prod"
	@echo "  make sitemap_other"
	@echo "  make sanitize_user_data ENV=development DBUSER=compathy DBPASS=compathypass DBHOST=localhost DBNAME=compathy2_development"
	@echo "  make maint_deploy MAINT_DATE=20150101"

init: server_setup
	@echo "//////////////////////"
	@echo "to finish, do below:"
	@echo "  * edit config config/application.yml"
	@echo "  * edit config config/database.yml"
	@echo "  * setup DB by $ make init_db if you need."

server_setup: bundle
	cp -i config/application.yml.sample config/application.yml
	cp -i config/database.yml.sample config/database.yml

reset_db: _reset_db _insert_init_data

_reset_db:
	bundle exec rake db:drop db:create db:schema:load

_insert_init_data:
	@echo "!!! please input mysql password for user 'compathy':"
	mysql -ucompathy -pcompathypass compathy2_development < db/init_places.dump
	mysql -ucompathy -pcompathypass compathy2_development < db/init_categories.dump
	bundle exec rake db:seed

reset_testdb:
	RAILS_ENV=test bundle exec rake db:drop db:create db:schema:load

reset_redis_development:
	redis-cli flushall
	bundle exec rake cy:init_ranking_this_week
	bundle exec rake cy:snap_tripnote_weekly_rank_periodically
	bundle exec rake cy:snap_tripnote_weekly_rank_periodically HOUR_AGO=4

bundle:
	bundle install --path=./vendor/bundler

migrate:
	RAILS_ENV=$(ENV) bundle exec rake db:migrate:status db:migrate db:migrate:status

init_db: _init_db reset_db

_init_db:
	mysql -uroot -p < db/init.sql

deploy: bundle migrate _assets_precompile _restart_unicorn _restart_delayed_job clear_rails_cache

deploy_cron_production: bundle _deploy_cron_production

_restart_unicorn:
	/etc/init.d/$(UNICORN) status
	/etc/init.d/$(UNICORN) restart
	/etc/init.d/$(UNICORN) status

_restart_delayed_job:
	RAILS_ENV=$(ENV) ./bin/delayed_job status
	RAILS_ENV=$(ENV) ./bin/delayed_job restart
	RAILS_ENV=$(ENV) ./bin/delayed_job status

_deploy_cron_production:
	crontab -l > /tmp/crontab.`date`
	crontab /home/cyuser/cron/compathy2/config/cron/crontab.cy-staff

_assets_precompile:
	RAILS_ENV=$(ENV) bundle exec rake assets:clean assets:precompile

clear_rails_cache:
	redis-cli KEYS "cache:*"
	redis-cli KEYS "cache:*" | xargs redis-cli DEL
	redis-cli KEYS "cache:*"

sitemap_prod:
	RAILS_ENV=production bundle exec rake sitemap:refresh

sitemap_other:
	RAILS_ENV=$(ENV) bundle exec rake sitemap:refresh:no_ping

rs:
	bundle exec rails server

rsd:
	bundle exec rails server --debugger

test: rspec karma eslint

rspec:
	RAILS_ENV=test bundle exec rake spec

karma:
	RAILS_ENV=test bundle exec rails server & # FIXME: necessary to get ERB-parsed js file
	sleep 3
	RAILS_ENV=test bundle exec rake karma:run

eslint:
	./node_modules/eslint/bin/eslint.js -c .eslintrc app/assets/javascripts/angular_subapp

sanitize_user_data:
	bundle exec rake jobs:clear
	mysql -h$(DBHOST) -u$(DBUSER) -p$(DBPASS) $(DBNAME) -e ' \
		SET @i := 0; \
		UPDATE `users` SET email = CONCAT("testuser", (@i := @i + 1), "@example.com"); \
	  UPDATE `users` SET receive_email=false, \
		                   receive_retention_mail=false, \
											 receive_fb_notification=false, \
											 receive_mobile_notification_other=false, \
											 receive_mobile_notification_spot=false, \
											 receive_mobile_notification_comment=false, \
											 receive_mobile_notification_like=false;'

maint_deploy:
	rm -rf public/maintenance*
	cp -rp maintenance/$(MAINT_DATE)/ public/maintenance/
	cd public/ && ln -s maintenance/maintenance.html

