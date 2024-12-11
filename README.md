# Projeto
Este projeto foi feito pela equipe da alura, e eu não tenho nenhum tipo de conhecimento em GO. Porém, este reposítório possui o intuíto de apredizado em integração contínua.


# Subindo o projeto
Este projeto possui um docker compose, que possui dois serviços. Do postgre e da aplicação. O projeto em si é um projeto de gerenciamento de alunos.
- Subindo o projeto
```bash
docker-compose up -d
```
- Aguarde o download das imanges e a subida da aplicação
- Depois de ter criado os containers, entre na url: http://localhost:8080/
- Se aparecer um erro 404, basta acessar o endpoint /alunos na url ou /seu-nome (ex: http://localhost:8080/cristhian )
- Caso entre com seu nome, a API do projeto vai retornar uma saudação

# Processo de automatização, esteira ambiente local.
 - Caso os container estejam rodando, execute: **docker-compose down** para parar os processo dos containers
 - Esteira de integração, teste de qualidade para verificar se a aplicação está tudo certa para que possa ser adicionada ao github
 - Cada linguagem possui seu próprio teste de qualidade, no caso do GO, pesquisei e encontrei **golangci-lint** Porém, vou utilizar uma imagem docker que já tem este comando para facilitar o teste e não precisar de instalar localmente na minha máquina por ser um projeto pequeno
 - Execute: 

```bash
docker run --rm -itv $(pwd):/app -w /app golangci/golangci-lint golangci-lint run controllers/ database/ models/ routes/
``` 
- Se a aplicação não retornar **nada** após o comando acima, deu tudo certo.
- Caso queira verificar se reamente deu tudo certo, execute: **echo $?** no terminal
- Se retornar 0, deu tudo certo. No mundo do linux, qualquer número diferente de 0 é erro.

- Inicie os containers e teste a aplicação com arquivo de teste presente na aplicação
```bash 
docker-compose up -d
docker exec <id-container> go test main_test.go
```
- Aguarde que todo o processo de test da aplicação seja feita, se retornar a seguinte mensagem de OK, os testes foram feitos com sucesso:
```bash
# saída esperada do teste
go: downloading github.com/stretchr/testify v1.7.0
go: downloading github.com/davecgh/go-spew v1.1.1
go: downloading gopkg.in/yaml.v3 v3.0.0-20210107192922-496545a6307b
go: downloading github.com/pmezard/go-difflib v1.0.0
ok      command-line-arguments  0.203

echo $?
0 # se retornar 0, deu tudo certo!
```

### Makefile
Para uma automação local, sem ficar precisando digitar os comandos anteriores  na mão, criei um Makefile na raiz do projeto. O Makefile é uma ferramenta de compilação, neste cenário criei para fins de automação.
- instalando o make: **sudo apt install make**
- Rode o comando **make ci**
```bash

# saída esperada
make ci
docker compose up -d 
[+] Running 2/3
 ⠹ Container ci-project_postgres_1  Recreated                                                                                                                                         1.2s 
 ✔ Container app                    Started                                                                                                                                           1.0s 
 ✔ Container ci-project-postgres-1  Started                                                                                                                                           0.2s 
docker run --rm -itv /home/cris/Documentos/estudos_projetos_devops/estudos_e_projetos/ci-cd/ci-project:/app -w /app golangci/golangci-lint golangci-lint run controllers/ database/ models/ routes/
docker exec app go test main_test.go
go: downloading github.com/stretchr/testify v1.7.0
go: downloading gopkg.in/yaml.v3 v3.0.0-20210107192922-496545a6307b
go: downloading github.com/davecgh/go-spew v1.1.1
go: downloading github.com/pmezard/go-difflib v1.0.0
ok      command-line-arguments  0.186s
``` 

# GitHub Actions
Neste cenário de esteira, por ser uma aplicação feita em GO e é pequena. Imagina se tiver uma aplicação de alta escala, os Dev não vão poder fazer testes, rodar arquivos Makefile em suas máquinas... Pra isso, criei uma pipe line no **GitHub Acitons**
- criando workflow
