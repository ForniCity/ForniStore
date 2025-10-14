<?php

return [
    'title' => 'Instalação',

    'welcome' => 'Azuriom é a <strong>próxima geração</strong> de CMS de jogos, é <strong>gratuito</strong> e <strong>open‑source</strong>, e é uma alternativa <strong>moderna, confiável, rápida e segura</strong> aos CMS existentes para que você possa ter a <strong>melhor experiência web possível</strong>.',

    'back' => 'Voltar',

    'requirements' => [
        'php' => 'PHP :version ou superior',
        'writable' => 'Permissão de escrita',
        'rewrite' => 'Reescrita de URL habilitada',
        'extension' => 'Extensão :extension',
        'function' => 'Função :function habilitada',
        '64bit' => 'PHP 64 bits',

        'refresh' => 'Atualizar requisitos',
        'success' => 'Azuriom está pronto para ser configurado!',
        'missing' => 'Seu servidor não possui os requisitos necessários para instalar o Azuriom.',

        'help' => [
            'writable' => 'Você pode tentar este comando para conceder permissão de escrita: <code>:command</code>.',
            'rewrite' => 'Você pode seguir as instruções em <a href="https://azuriom.com/docs/installation" target="_blank" rel="noopener noreferrer">nossa documentação</a> para habilitar a reescrita de URL.',
            'htaccess' => 'O arquivo <code>.htaccess</code> ou <code>public/.htaccess</code> está faltando. Certifique‑se de que os arquivos ocultos estão habilitados e que o arquivo esteja presente.',
            'extension' => 'Você pode tentar este comando para instalar as extensões PHP ausentes: <code>:command</code>.<br>Depois disso, reinicie o Apache ou Nginx.',
            'function' => 'Você precisa habilitar esta função no arquivo php.ini do PHP editando o valor de <code>disable_functions</code>.',
        ],
    ],

    'database' => [
        'title' => 'Banco de dados',

        'type' => 'Tipo',
        'host' => 'Host',
        'port' => 'Porta',
        'database' => 'Banco de dados',
        'user' => 'Usuário',
        'password' => 'Senha',

        'warn' => 'Este tipo de banco de dados não é recomendado e deve ser usado apenas quando não for possível fazer de outra forma.',
    ],

    'game' => [
        'title' => 'Jogo',

        'locale' => 'Localidade',

        'warn' => 'Atenção, uma vez que a instalação esteja concluída, não será possível alterar o jogo ou o método de login sem reinstalar completamente o Azuriom!',

        'install' => 'Instalar',

        'user' => [
            'title' => 'Conta de administrador',

            'name' => 'Nome',
            'email' => 'Endereço de e‑mail',
            'password' => 'Senha',
            'password_confirm' => 'Confirmar senha',
        ],

        'minecraft' => [
            'premium' => 'Login com conta Microsoft (mais seguro, mas requer ter adquirido o Minecraft)',
        ],

        'steam' => [
            'profile' => 'URL do perfil Steam',
            'profile_info' => 'Este usuário Steam será administrador no site.',

            'key' => 'Chave da API Steam',
            'key_info' => 'Você pode encontrar sua chave da API Steam em <a href="https://steamcommunity.com/dev/apikey" target="_blank" rel="noopener noreferrer">Steam</a>.',
        ],

        'epic' => [
            'id' => 'ID Epic da sua conta',
            'id_info' => 'Este usuário será administrador no site. Você pode encontrar seu ID Epic na sua <a href="https://www.epicgames.com/account/personal" target="_blank" rel="noopener noreferrer">conta Epic Games</a>.',

            'client_id' => 'ID do Cliente Epic Games',
            'client_secret' => 'Segredo do Cliente Epic Games',

            'steps' => 'Para obter o Client ID e o Client Secret, siga estas etapas:',
            'step_1' => 'Acesse o <a href="https://dev.epicgames.com/portal/" target="_blank" rel="noopener noreferrer">Portal de Desenvolvedores da Epic Games</a> e crie um novo produto.',
            'step_2' => 'Nas configurações do produto, na guia "Clientes", crie um novo cliente com o tipo de política "GameClient" e o seguinte URL de redirecionamento: <code>:redirect</code>',
            'step_3' => 'Você pode encontrar o Client ID e o Client Secret nas configurações do cliente (Editar à direita do cliente).',
        ],
    ],

    'success' => [
        'thanks' => 'Obrigado por escolher o Azuriom!',
        'success' => 'Seu site foi instalado com sucesso, agora você pode usar seu site e fazer algo incrível!',
        'go' => 'Começar',
        'support' => 'Se você aprecia o Azuriom e o trabalho que fornecemos, por favor não se esqueça de <a href="https://azuriom.com/support-us" target="_blank" rel="noopener noreferrer">nos apoiar</a>.',
    ],
];