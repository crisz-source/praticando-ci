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
 - Caso os container estejam rodando, execute: **docker-compose down** para encerrar os processo dos containers
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
- **criando workflow:** Acessando o repositório, clique em **actions** e pesquise por **Go**, selecione no canto esquerdo **Continuous integration** e clique em **configure** para inicializar a configuração de pipeline, um template.. Exemplo do que vai ser criado:
```bash
# This workflow will build a golang project
# For more information see: https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-go

name: Integração Contínua

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:

  build: # <--------- job
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Set up Go
      uses: actions/setup-go@v4
      with:
        go-version: '1.20'

    - name: Build
      run: go build -v ./...

    - name: Test
      run: go test -v ./...
```
## 
- **Configurando o arquivo go.yml:** Nesta aplicação, não vai ser permitido fazer um **push** diretamente na branch **main**, neste repositório em específico vai ter um **merge** o tempo todo para a branch main, mas nunca um commit **diretamente** na **main**. Então, sempre que executar este workflow vai ter um **pull request** aberto para a branch main
## 

- **Entendendo os jobs:** = O jobs são passos, nada mais do que um **"ci"** que consta no arquivo **Makefile** um conjunto de passos que será executado

- **runs-on: ubuntu-latest** = Em qual tipo de servidor este job **"Build"** vai ser executado, que neste caso vai ser na ultima versao do ubuntu que os servidores do github actions tiver

- **steps:** Etapas, passos, primeiramente o código que esta no repositório, **precisa está nos servidores** do **github actions** e isso já esta sendo feito por conta do uses: **actions/checkout@v4**. Basicamente o **uses: actions/checkout@v4** faz um gitclone e entra no projeto

- **name: Set up Go** = Esta actions, basicamente esta fazendo uma instalação do **Go** diretamente no servidor linux, essa action esta definindo a **versão do Go** para action **actions/setup-go@v4** 

- **name: Build** Processo de comandos que vão ser realizados, no campo **name** consegue alterar para qualquer nome, a linha que vai fazer o disparo de comando é o **run**  

- **run: go build -v ./...** comando que vai realizar o build da aplicação, ou inciar um container por exemplo: **run: docker-compose up -d postgres**

## 
### go.yml modificado: 
```bash
# This workflow will build a golang project
# For more information see: https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-go

name: Integração Contínua

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:

  ci:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Set up Go
      uses: actions/setup-go@v4
      with:
        go-version: '1.22'

    - name: Inicia o banco de dados
      run: docker-compose up -d postgres

    - name: Lint
      run: docker run --rm -itv $(CURDIR):/app -w /app golangci/golangci-lint golangci-lint run controllers/ database/ models/ routes/

    - name: Test
      run: go test main_test.go

```
- Depois dessa configuração, clique em **commit > Commit changes**  e vá em **actions** note que o workflow já está sendo executado, de primeira instancia vai falhar, pois não é uma boa prática que qualquer commit seja feito no projeto o worflow vai ser acionado. Para garantir que isso não aconteça, será necessário configurar as retrições de branches para que situações como esta não aconteça e garantir que este workflow seja de uma integração contínua.

## Restrições
- Nessas restrições, não vai permitir **push** diretamente na branch **main** e permitir apenas que um **pull request** seja **mesclado** (merge) com a branch **main** se o **job (ci)** passar, ou seja, se o **ci** for **concluído** com sucesso

## Passos e configurações das restrições de branch:
- vá em settings > branches (no menu lateral esquerdo) > Add branch ruleset

- **Ruleset Name:** Defina um **nome** para o Ruleset

- **Enforcement status:** Active, ativando as regras

- **Bypass list** Basicamente é tudo, seja pessoas, organizações, times que podem ignorar as regras, deixar vazio do jeito que está.

- **Target branches** Defina a branche que será aplicada a regra, **clique** em Add Target > Include default branch

- **Rules:** Desmarque a opção **Restrict deletions** e marque a opção **Require a pull request before merging** para exigir que um pull request seja feito antes de fazer um merge, em **Required approvals** deixe 0, se a organização tiver mais pessoas é interessante marcar 1 ou mais pessoas para autorizar o pull request, marque a opção 
**Require status checks to pass** para garantir que **pull request** seja feito apenas se a verificação do **ci** for **concluída**: Clique em Add checks > -digite o nome do job- > selecione o job. Deixe marcado a opção **Block force pushes** e por fim, clique em **create** se retornar a mensagem: **Ruleset created** deu tudo certo, a partir de agora, não é possível fazer um push diretamente na main, será necessário realizar um pull request e este pull request só vai ser com **sucesso** se o job **ci** for **concluído** com sucesso

## 
### Testando as restrições
- crie uma nova branch e mude para ela
```bash
git switch -c pull_request
```
- Note que no código acima em go.yaml esta da seguinte maneira:
```bash
run: docker run --rm -itv $(CURDIR):/app -w /app golangci/golangci-lint golangci-lint run controllers/ database/ models/ routes/
```
- a variável **$(CURDIR)** funciona apenas no cenário se for utilizar um Makefile, neste caso modifiquei para pwd
```bash
run: docker run --rm -itv $(pwd):/app -w /app golangci/golangci-lint golangci-lint run controllers/ database/ models/ routes/
```
- com essa alteração, adicionei essas modificação no meu repositorio na branch pull_request
```bash
git add .github/
git commit -m "Correção do lint"
git push origin pull_request
```

### Executando a pipeline
- Criando pull request para fazer merge na branch main, e só vai fazer o merge se o **status** do job **ci** for **concluído**
- **Pull request:**  Entre no seu repositório, se aparecer a seguinte mensagem: **pull_request had recent pushes 4 minutes ago** **clique em Compare & pull request** se não apareceu, clique em Pull request > New pull request
- na pagina **Open a pull request** em base, selecione a branch principal, pois a branch pull request vai comparar com a main e fazer um merge
- Pode verificar o que foi mudado descendo um pouco a baixo da pagina
- Clique em **Create pull request**
- Note que o pull request vai começar a fazer alguns checkes e executar o **job ci**
- Durante a execução, o proprio job ci me informou o seguinte erro: **/home/runner/work/_temp/6814968e-30bd-4a48-8fef-8acc4a3dca77.sh: line 1: docker-compose: command not found** ou seja, o docker-compose não está instalado no servidor github actions, neste caso adicionei um passo para realizar a instalação do docker-compose antes de iniciar o banco de dados
```bash
- name: Install Docker Compose
  run: |
    sudo apt-get update
    sudo apt-get install -y docker-compose
```
- Com a instalação do docker-compose, caso retorne um outro error do Lint, pois ele esta esperando que o comando execute em um terminal interativo, pois os servidores do github actions não possui esses tipo de terminal. Para resolver isso, adicionei uma nova **actions** para que o comando de **interação do docker** seja feito com sucesso. Fiz uma substituição do comando **run** para um **uses**
```bash
# removi
- name: Lint 
  run: docker run --rm -itv $(pwd):/app -w /app golangci/golangci-lint golangci-lint run controllers/ database/ models/ routes/

#adicionei:

- name: Lint
      uses: golangci/golangci-lint-action@v6
      with:
          version: v1.60
```
- Passando como **argumento**, o quais pastas o **Lint** deverá analisar o código
```bash
- name: Lint
      uses: golangci/golangci-lint-action@v6
      with:
          version: v1.60
          args: controllers/ database/ models/ routes/ # argumentos
```
- Mandando para a branch pull_request, e verifique o processo de integração continua, e clicando no seu repositório > pull request > nome do pull request >  em datails consegue verificar todos os passos serem feitos
```bash
git add .\.github\
git commit -m "Usando actions de golangci-lint"
git push origin pull_request
```

- Criando variáveis de ambiente no github actions, para acessar o banco de dados durante a integração contínua, configurando as secrets..

- Vá em settings > Secrets and variables (no menu lateral esquerdo) > Secrets > Repository secrets > New repository secret

- Nas secrets, adicione as variaveis de ambiente do banco de dados, que neste caso é o **DB_HOST | DB_PASSWORD | DB_USER | DB_NAME | DB_PORT** e adicione os valores de cada um em **Secret**

- Utilizando as variaveis de ambiente criada no github actions

- foi adicionado em test pois durante a execução da integração, recebi o seguinte erro: **[error] failed to initialize database, got error cannot parse `host= user= *** dbname= port=`: invalid port** 
```bash
- name: Test
      run: DB_HOST=${{ secrets.DB_HOST }} DB_PASSWORD=${{ secrets.DB_PASSWORD }} DB_USER=${{ secrets.DB_USER }} DB_NAME=${{ secrets.DB_NAME }} DB_PORT=${{ secrets.DB_PORT }} go test main_test.go
```

# Resumo de como funciona CI/CD
- **Integração Contínua:** A integração contínua está mais focada na automação de builds e execução de testes automatizados (como testes unitários, de integração, etc.) sempre que um dev faz mudanças no código e envia para o repositório (por exemplo, usando Git). Caso haja erros nos testes ou na build, o processo é interrompido, e o time é notificado para corrigir os problemas antes de avançar.

- **Entrega Contínua:** Entrega contínua inclui a automação do build, testes e deploy para ambientes de homologação, mas a entrega para produção ainda depende de uma aprovação manual. Isso permite revisões finais antes de liberar para a produção

### Tabeça das diferença principais
```bash

###############################################################################################################################################################################
| Aspecto             | Integração Contínua (CI)                                 | Entrega Contínua (CD)                                                                      #
|---------------------|----------------------------------------------------------|---------------------------------------------------------                                   #
| Foco                | Garantir que o código está correto                       | Garantir que o código validado pode ir para produção                                       #     
| Automação           | Compilação, testes unitários e integração                | Inclui a automação de deploys para  produção                                               #     
| Produção?           | Não faz deploy em produção diretamente                   | Código pode ser entregue, mas o deploy em produção ainda pode exigir aprovação manual      #
| Objetivo final      | Detectar problemas no código rapidamente                 | Reduzir o tempo entre desenvolvimento e entrega com segurança                              #          
###############################################################################################################################################################################                        
```