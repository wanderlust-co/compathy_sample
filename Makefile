
usage:
	@echo "USAGE:"
	@echo "make_insert_init_data"

_insert_init_data:
	mysql -uroot -p compathy-clone_development < db/init_places.dump
	mysql -uroot -p compathy-clone_development < db/init_categories.dump
