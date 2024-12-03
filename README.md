# LoveNetwork
Biblioteca em Lua que simplifica a criação de clientes e servidores, oferecendo ferramentas para gerenciar conexões, eventos de rede e comunicação de dados, ideal para aplicações como jogos multiplayer.

---

## Pré-requisitos

Antes de usar a biblioteca, você precisará instalar os seguintes softwares e bibliotecas:

1. **Lua**: Linguagem base utilizada.
2. **Love2D**: Framework de desenvolvimento de jogos 2D.
3. **LuaRocks**: Gerenciador de pacotes para Lua.
4. **LuaSocket**: Biblioteca para comunicação via rede.

---

## Configuração do Ambiente

### **1. Instalar o Lua**

Baixe e instale o Lua:  
- Acesse o site oficial [lua.org](https://www.lua.org/download.html).
- Baixe a versão mais recente compatível com seu sistema operacional.
- Siga as instruções de instalação.

### **2. Instalar o Love2D**

O Love2D é essencial para rodar projetos que utilizam o **LoveNetwork**.  

- Acesse o site oficial [love2d.org](https://love2d.org/).
- Baixe a versão para o seu sistema operacional e instale.

### **3. Instalar o LuaRocks**

O **LuaRocks** é um gerenciador de pacotes para Lua que facilita a instalação de bibliotecas como o **LuaSocket**.

#### **Passos para Instalação:**

1. **Baixar o instalador:**
   - Acesse o site oficial [lua.rocks](https://luarocks.org/).
   - Siga as instruções para baixar o instalador compatível com o seu sistema operacional.

2. **Instalar o LuaRocks:**
   - Execute o instalador seguindo as instruções fornecidas no site.

3. **Configurar o ambiente (se necessário):**
   - Certifique-se de que o diretório de instalação do LuaRocks foi adicionado ao seu `PATH`.

Após a instalação, você estará pronto para gerenciar pacotes Lua, como o **LuaSocket**, essencial para o **LoveNetwork**.

### **4. Instalar o LuaSocket**

O **LuaSocket** é uma biblioteca necessária para a comunicação em rede e deve ser instalada antes de utilizar o **LoveNetwork**.

#### **Instalando o LuaSocket com LuaRocks**

1. **Abrir o terminal:**
   - Certifique-se de que o LuaRocks já esteja configurado corretamente no seu sistema.

2. **Executar o comando de instalação:**
   - Digite o seguinte comando no terminal:
     ```bash
     luarocks install luasocket
     ```

### **5. Instalar a Biblioteca LoveNetwork**

Após configurar o ambiente, instalar o Love2D, o LuaRocks e o LuaSocket, o próximo passo é integrar e utilizar a biblioteca **LoveNetwork**.

#### **Passo a passo para obter o LoveNetwork:**

1. **Baixar o repositório LoveNetwork:**
   - Clone o repositório usando o Git:
     ```bash
     git clone https://github.com/MatheusPK/LoveNetwork.git
     ```

2. **Acessar a documentação completa:**
   - Para instruções detalhadas de configuração e uso da biblioteca, acesse a **[Wiki do LoveNetwork]([https://github.com/MatheusPK/LoveNetwork/wiki](https://github.com/MatheusPK/LoveNetwork/wiki/Documenta%C3%A7%C3%A3o))**.
   - A Wiki contém exemplos práticos de configuração de servidor e cliente, dicas de uso e informações sobre os principais componentes da biblioteca.

#### **Nota importante:**
A **LoveNetwork** é voltada para desenvolvedores com experiência em **Love2D** e um entendimento básico de redes e comunicação em tempo real. Se você não está familiarizado com esses conceitos, recomendamos estudar **Love2D** e fundamentos de redes antes de utilizar a biblioteca.

Agora você está pronto para explorar as funcionalidades da **LoveNetwork** e criar jogos multiplayer incríveis com **Love2D**!
