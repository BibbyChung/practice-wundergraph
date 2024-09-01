
p-up:
	cd ./ops/prod && docker compose -p practice-wundergraph up
p-down:
	cd ./ops/prod && docker compose -p practice-wundergraph down
p-build:
	cd ./ops/prod && docker compose -p practice-wundergraph build
p-logs:
	cd ./ops/prod && docker compose -p practice-wundergraph logs -f