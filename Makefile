
usage:
		@echo "USAGE:"
		@echo "  make _insert_init_data"

_insert_init_data:
		mysql -uroot -p compathy-clone_development < db/init_places.dump

