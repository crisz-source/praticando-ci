# Projoeto
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
