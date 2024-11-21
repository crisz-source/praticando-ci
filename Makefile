lint: # aqui são tarefas, pode colocar qualquer nome que desejar e logo abaixo dentro da tarefa é o comando de teste
	docker run --rm -itv $(CURDIR):/app -w /app golangci/golangci-lint golangci-lint run controllers/ database/ models/ routes/
test:
	docker exec app go test main_test.go
start: # garantindo que a aplicação esteja de pé
	docker compose up -d 
ci: start lint test # quando executar o comando make ci, o Makefile vai rodar a tarefa start para iniciar a aplicação em containers,  lint para fazer os testes e depois a tarefa test que vai rodar os testes da aplicação