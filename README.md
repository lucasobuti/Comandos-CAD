# **Descrição dos scripts** 
> Observação: AutoCAD precisa estar em inglês

### 1. num\_model.lsp 
- Numeração das páginas
	- Os textos “PAG” de cada prancha devem estar na layer com o nome ```PAGINA``` (sem acento) e escritos exatamente como ```PAG```, pois é assim que o script identifica e faz a numeração **(os templates novos já estão neste formato)**;

### 2\. pagina.lsp 
- Substituir qualquer numeração existente na layer ```PAGINA``` por ```PAG```, permitindo reorganizar a numeração das páginas em caso de ajustes.

### 3\. TPL\_PLOT.lsp
- plotar as pranchas
	- Para que o script funcione, cada prancha deve ter um retângulo ao redor. Esse retângulo precisa estar em uma layer específica chamada ```RECTANGLE```, **(os templates novos já estão neste formato)**.
	- Para alterar o caminho onde as páginas serão salvas, é necessário abrir o arquivo TPL\_PLOT.lsp no Bloco de Notas e editar o campo ```(setq path "C:\\\\...")```, lembrando de usar duas contrabarras ```\\``` em vez de apenas uma. No código tem um exemplo.

# **Como carregar os scripts no CAD:**

1. No CAD, digite o comando ```APPLOAD``` e execute;
2. Na janela do explorador de arquivos procure a pasta onde o .lsp esta salvo e clique em ```LOAD```;
3. Na parte inferior do explorador de arquivos ele vai indicar o status, se aparecer ```XXX.lsp successfully loaded``` deu certo; **(Se quiser pode carregar mais de uma script de uma vez, so precisa verificar se todos foram carregados com sucesso)**.
4. Executar o comando para o script em questão que foi carregado. Os comandos para cada .lsp estão logo abaixo.


# **Lista de Comandos:**

**num\_model.lsp** -> ```NUMPAG```

 **pagina** -> ```RESETPAGINA```
 
 **TPL\_PLOT** -> ```TPL_PLOT```


