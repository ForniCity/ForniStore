<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Linhas de idioma do administrador
    |--------------------------------------------------------------------------
    |
    | As seguintes linhas de idioma são usadas no painel de administração
    |
    */

    'nav' => [
        'dashboard' => 'Painel',
        'settings' => [
            'heading' => 'Configurações',
            'settings' => 'Configurações',
            'global' => 'Geral',
            'security' => 'Segurança',
            'performances' => 'Desempenho',
            'home' => 'Página inicial',
            'auth' => 'Autenticação',
            'mail' => 'E‑mail',
            'maintenance' => 'Manutenção',
            'social' => 'Links sociais',
            'navbar' => 'Barra de navegação',
            'servers' => 'Servidores',
        ],

        'users' => [
            'heading' => 'Usuários',
            'users' => 'Usuários',
            'roles' => 'Funções',
            'bans' => 'Banimentos',
        ],

        'content' => [
            'heading' => 'Conteúdo',
            'pages' => 'Páginas',
            'posts' => 'Postagens',
            'images' => 'Imagens',
            'redirects' => 'Redirecionamentos',
        ],

        'extensions' => [
            'heading' => 'Extensões',
            'plugins' => 'Plugins',
            'themes' => 'Temas',
        ],

        'other' => [
            'heading' => 'Outros',
            'update' => 'Atualizar',
            'logs' => 'Logs',
        ],

        'profile' => [
            'profile' => 'Perfil',
        ],

        'back' => 'Voltar ao site',
        'support' => 'Suporte',
        'documentation' => 'Documentação',
    ],

    'delete' => [
        'title' => 'Excluir?',
        'description' => 'Tem certeza de que deseja excluir isto? Você não poderá voltar!',
    ],

    'footer' => 'Desenvolvido por :azuriom &copy; :year. Painel projetado por :startbootstrap.',

    /*
    |
    | Páginas de administração
    |
    */

    'dashboard' => [
        'title' => 'Painel',

        'users' => 'Usuários',
        'posts' => 'Postagens',
        'pages' => 'Páginas',
        'images' => 'Imagens',

        'update' => 'Uma nova versão do Azuriom está disponível: :version',
        'http' => 'Seu site não está usando https, você deve habilitá‑lo e forçá‑lo para sua segurança e a dos usuários.',
        'cloudflare' => 'Se você estiver usando Cloudflare, deve instalar o plugin Cloudflare Support.',
        'recent_users' => 'Usuários recentes',
        'active_users' => 'Usuários ativos',
        'emails' => 'E‑mails estão desativados. Se um usuário esquecer sua senha, não poderá redefini‑la. Você pode habilitar e‑mails nas <a href=":url">configurações de e‑mail</a>.',
    ],

    'settings' => [
        'index' => [
            'title' => 'Configurações globais',

            'name' => 'Nome do site',
            'url' => 'URL do site',
            'description' => 'Descrição do site',
            'meta' => 'Palavras‑chave meta',
            'meta_info' => 'As palavras‑chave devem ser separadas por vírgula.',
            'favicon' => 'Favicon',
            'background' => 'Plano de fundo',
            'logo' => 'Logo',
            'timezone' => 'Fuso horário',
            'locale' => 'Localidade',
            'money' => 'Nome da moeda do site',
            'copyright' => 'Copyright',
            'user_money_transfer' => 'Habilitar transferência de dinheiro entre usuários',
            'site_key' => 'Chave do site para azuriom.com',
            'site_key_info' => 'A chave do site do azuriom.com é necessária para instalar extensões premium adquiridas no mercado. Você pode obter sua chave do site em seu <a href="https://market.azuriom.com/profile" target="_blank" rel="noopener norefferer">perfil Azuriom</a>.',
            'webhook' => 'URL do Webhook do Discord para postagens',
            'webhook_info' => 'Um webhook do Discord será enviado para este URL ao criar uma nova postagem, se a data de publicação não estiver no futuro. Deixe em branco para desativar.',
        ],

        'security' => [
            'title' => 'Configurações de segurança',

            'captcha' => [
                'title' => 'Captcha',
                'site_key' => 'Chave do site',
                'secret_key' => 'Chave secreta',
                'recaptcha' => 'Você pode obter chaves reCAPTCHA no <a href="https://www.google.com/recaptcha/" target="_blank" rel="noopener noreferrer">site do Google reCAPTCHA</a>. Você precisa usar chaves reCAPTCHA <strong>v2 invisível</strong>.',
                'hcaptcha' => 'Você pode obter chaves hCaptcha no <a href="https://www.hcaptcha.com/" target="_blank" rel="noopener noreferrer">site do hCaptcha</a>.',
                'turnstile' => 'Você pode obter chaves do Turnstile no <a href="https://dash.cloudflare.com/?to=/:account/turnstile" target="_blank" rel="noopener noreferrer">painel do Cloudflare</a>. Você deve selecionar o widget "Managed".',
                'login' => 'Habilitar captcha na página de login',
            ],

            'hash' => 'Algoritmo de hash',
            'hash_error' => 'Este algoritmo de hash não é suportado pela sua versão atual do PHP.',
            'force_2fa' => 'Exigir 2FA para acesso ao painel de administração',
        ],

        'performances' => [
            'title' => 'Configurações de desempenho',

            'cache' => [
                'title' => 'Limpar cache',
                'clear' => 'Limpar cache',
                'description' => 'Limpar o cache do site.',
                'error' => 'Erro ao limpar o cache.',
            ],

            'boost' => [
                'title' => 'AzBoost',
                'description' => 'AzBoost melhora o desempenho do seu site adicionando mais uma camada exclusiva de cache.',
                'info' => 'Se você tiver alguns problemas após habilitar uma extensão, você deve recarregar o cache.',

                'enable' => 'Ativar AzBoost',
                'disable' => 'Desativar AzBoost',
                'reload' => 'Recarregar AzBoost',

                'status' => 'AzBoost está atualmente :status.',
                'enabled' => 'ativado',
                'disabled' => 'desativado',

                'error' => 'Erro ao ativar o AzBoost.',
            ],
        ],

        'seo' => [
            'title' => 'Configurações da página inicial',

            'html' => 'Você pode incluir HTML no <code>&lt;head&gt;</code> ou <code>&lt;body&gt;</code> de todas as páginas (por exemplo, para banner de cookies ou análises do site) criando um arquivo chamado <code>head.blade.php</code> ou <code>body.blade.php</code> na pasta <code>resources/views/custom/</code>.',
            'home_message' => 'Mensagem da página inicial',

            'welcome_alert' => [
                'enable' => 'Ativar pop‑up de boas‑vindas?',
                'message' => 'Mensagem do pop‑up de boas‑vindas',
                'info' => 'Este pop‑up será exibido na primeira vez que um usuário visitar o site.',
            ],
        ],

        'auth' => [
            'title' => 'Autenticação',

            'conditions' => 'Condições a serem aceitas no registro',
            'conditions_info' => 'Links em formato Markdown, por exemplo: <code>Eu aceito os [termos](/conditions-link) e a [política de privacidade](/privacy-policy)</code>.',
            'registration' => 'Habilitar registro de usuários',
            'registration_info' => '<strong>O botão “Registrar” é removido quando esta opção está desativada.</strong> Alguns plugins ainda podem permitir a criação de novas contas de usuário.',
            'api' => 'Habilitar API de autenticação',
            'api_info' => 'Esta API permite que você adicione uma autenticação personalizada ao seu servidor de jogo. Para servidores de Minecraft usando um launcher, você pode usar o <a href="https://github.com/Azuriom/AzAuth" target="_blank" rel="noopener noreferrer">AzAuth</a> para uma integração fácil e rápida.',
            'user_change_name' => 'Permitir que os usuários alterem o nome de usuário a partir do perfil',
            'user_avatar' => 'Permitir que os usuários enviem seu próprio avatar no perfil',
            'user_delete' => 'Permitir que os usuários excluam sua conta a partir do perfil',
        ],

        'mail' => [
            'title' => 'Configurações de e‑mail',
            'from' => 'Endereço de e‑mail usado para enviar e‑mails.',
            'mailer' => 'Tipo de e‑mail',
            'info' => 'Para mais informações sobre a configuração de e‑mails, consulte a <a href="https://azuriom.com/docs/mails" target="_blank" rel="noopener noreferrer">documentação</a>.',
            'disabled' => 'Quando os e‑mails estão desativados, os usuários não poderão redefinir sua senha se a esquecerem.',
            'sendmail' => 'Usar Sendmail não é recomendado e você deve usar um servidor SMTP quando possível.',
            'smtp' => [
                'host' => 'Endereço do host SMTP',
                'port' => 'Porta do host SMTP',
                'scheme' => 'Protocolo',
                'username' => 'Nome de usuário do servidor SMTP',
                'password' => 'Senha do servidor SMTP',
            ],
            'verification' => 'Habilitar verificação de endereço de e‑mail do usuário',
            'send' => 'Enviar um e‑mail de teste',
            'sent' => 'O e‑mail de teste foi enviado com sucesso.',
            'missing' => 'Nenhum endereço de e‑mail foi especificado na conta :user.',
        ],

        'maintenance' => [
            'title' => 'Configurações de manutenção',

            'enable' => 'Ativar manutenção',
            'message' => 'Mensagem de manutenção',
            'global' => 'Ativar manutenção em todo o site',
            'paths' => 'Caminhos para bloquear durante a manutenção',
            'info' => 'Você pode usar <code>/*</code> para bloquear todas as páginas que começam com o mesmo caminho. Por exemplo, <code>/news/*</code> bloqueará o acesso a todas as notícias.',
        ],

        'updated' => 'As configurações foram atualizadas.',
    ],

    'navbar_elements' => [
        'title' => 'Barra de navegação',
        'edit' => 'Editar elemento da barra de navegação :element',
        'create' => 'Criar elemento da barra de navegação',

        'restrict' => 'Limitar funções que poderão ver este elemento',
        'dropdown' => 'Depois que este menu suspenso for salvo, itens podem ser adicionados a ele via arrastar e soltar na página principal da barra de navegação.',

        'fields' => [
            'home' => 'Home',
            'link' => 'Link externo',
            'page' => 'Página',
            'post' => 'Postagem',
            'posts' => 'Lista de postagens',
            'plugin' => 'Plugin',
            'dropdown' => 'Menu suspenso',
            'new_tab' => 'Abrir em nova guia',
        ],

        'updated' => 'Barra de navegação atualizada.',
        'not_empty' => 'Você não pode excluir menu suspenso com elementos.',
    ],

    'social_links' => [
        'title' => 'Links sociais',
        'edit' => 'Editar link social :link',
        'create' => 'Adicionar link social',
    ],

    'servers' => [
        'title' => 'Servidores',
        'edit' => 'Editar servidor :server',
        'create' => 'Adicionar servidor',

        'default' => 'Servidor padrão',
        'default_info' => 'O número de jogadores conectados do servidor padrão será exibido no site se o tema atual suportar.',

        'home_display' => 'Exibir este servidor na página inicial',
        'url' => 'URL do botão de ingressar',
        'url_info' => 'Deixe em branco para exibir o endereço do servidor. Pode ser um link para baixar o jogo/launcher ou uma URL para ingressar no servidor como <code>steam://connect/&lt;ip&gt;</code>.',

        'ping_info' => 'O link de ping não precisa de um plugin, mas você não pode executar comandos com ele.',
        'query_info' => 'Com o link de consulta, não é possível executar comandos no servidor.',

        'query_port_info' => 'Pode ficar vazio se for o mesmo que a porta do jogo.',

        'verify' => 'Testar comandos instantâneos',

        'rcon_password' => 'Senha Rcon',
        'rcon_port' => 'Porta Rcon',
        'query_port' => 'Porta Query Source',
        'unturned_info' => 'Você precisa usar o tipo SRCDS RCON no OpenMod. O RocketMod RCON não é compatível!',

        'azlink' => [
            'port' => 'Porta AzLink',

            'link' => 'Para vincular seu servidor ao seu site usando o AzLink:',
            'link1' => '<a href="https://azuriom.com/azlink">Baixe o plugin AzLink</a> e instale‑o em seu servidor.',
            'link2' => 'Reinicie o servidor.',
            'link3' => 'Execute este comando no servidor: ',
            'auth' => 'Para registrar automaticamente os usuários no site, você pode habilitar a integração do seu sistema de autenticação (AuthMe, etc.) na configuração do AzLink.',

            'info' => 'Se você estiver tendo problemas com o AzLink ao usar o Cloudflare ou um firewall, tente seguir os passos na <a href="https://azuriom.com/docs/faq" target="_blank" rel="noopener norefferer">FAQ</a>.',
            'command' => 'Você pode vincular seu servidor ao seu site com o comando: ',
            'port_command' => 'Se você estiver usando uma porta AzLink diferente da padrão, você deve configurá‑la com o comando: ',
            'ping' => 'Ativar comandos instantâneos (requer uma porta aberta no servidor)',
            'ping_info' => 'Quando os comandos instantâneos não estão ativados, os comandos serão executados com um atraso de 30 segundos a 1 minuto.',
            'custom_port' => 'Usar uma porta AzLink personalizada',

            'error' => 'A conexão com o servidor falhou, o endereço e/ou a porta estão incorretos ou a porta está fechada.',
            'badresponse' => 'A conexão com o servidor falhou (código :code), o token é inválido ou o servidor está mal configurado. Você pode refazer o comando de vinculação para corrigir isso.',
        ],

        'players' => ':count jogador|:count jogadores',
        'offline' => 'Offline',

        'connected' => 'A conexão com o servidor foi feita com sucesso!',
        'error' => 'A conexão com o servidor falhou: :error',

        'type' => [
            'mc-ping' => 'Minecraft Ping',
            'mc-rcon' => 'Minecraft RCON',
            'mc-azlink' => 'AzLink',
            'source-query' => 'Consulta Source',
            'source-rcon' => 'Source RCON',
            'steam-azlink' => 'AzLink',
            'bedrock-ping' => 'Ping Bedrock',
            'bedrock-rcon' => 'RCON Bedrock',
            'fivem-status' => 'Status FiveM',
            'fivem-rcon' => 'RCON FiveM',
            'rust-rcon' => 'RCON Rust',
            'flyff-server' => 'Servidor Flyff',
        ],
    ],

    'users' => [
        'title' => 'Usuários',
        'edit' => 'Editar usuário :user',
        'create' => 'Criar usuário',

        'registered' => 'Registrado em',
        'last_login' => 'Último login em',
        'ip' => 'Endereço IP',

        'admin' => 'Administrador',
        'banned' => 'Banido',
        'deleted' => 'Excluído',

        'ban' => 'Banir',
        'unban' => 'Desbanir',
        'delete' => 'Excluir',

        'alert-deleted' => 'Este usuário está excluído, não pode ser editado.',
        'alert-banned' => [
            'title' => 'Este usuário está atualmente banido:',
            'banned-by' => 'Banido por: :author',
            'reason' => 'Motivo: :reason',
            'date' => 'Data: :date',
        ],

        'edit_profile' => 'Editar perfil',

        'info' => 'Informações do usuário',

        'ban-title' => 'Banir :user',
        'ban-description' => 'Tem certeza de que deseja banir este usuário?',

        'email' => [
            'verify' => 'Verificar e‑mail',
            'verified' => 'Endereço de e‑mail verificado',
            'date' => 'Sim, em :date',
            'verify_success' => 'O endereço de e‑mail foi verificado.',
        ],

        '2fa' => [
            'title' => 'Autenticação de Dois Fatores',
            'secured' => '2FA ativado',
            'disable' => 'Desativar 2FA',
            'disabled' => 'A Autenticação de Dois Fatores foi desativada.',
        ],

        'password' => [
            'title' => 'Última mudança de senha',
            'force' => 'Forçar alteração',
            'forced' => 'Deve alterar a senha',
        ],

        'status' => [
            'banned' => 'Este usuário está agora banido.',
            'unbanned' => 'Este usuário foi desbanido.',
        ],

        'discord' => 'Conta do Discord vinculada',

        'notify' => 'Enviar uma notificação',
        'notify_info' => 'Enviar uma notificação para este usuário',
        'notify_all' => 'Enviar uma notificação para todos os usuários',
    ],

    'roles' => [
        'title' => 'Funções',
        'edit' => 'Editar função :role (#:id)',
        'create' => 'Criar função',

        'info' => '(ID: :id, Poder: :power)',

        'default' => 'Padrão',
        'admin' => 'Administrador',
        'admin_info' => 'Quando o grupo é administrador, ele tem todas as permissões.',

        'updated' => 'As funções foram atualizadas.',
        'unauthorized' => 'Esta função é superior à sua própria função.',
        'add_admin' => 'Você não pode adicionar a permissão de administrador a uma função.',
        'remove_admin' => 'Você não pode remover a permissão de administrador da sua função.',
        'no_admin' => 'Deve haver pelo menos um outro usuário administrador para remover sua função de administrador.',
        'delete_default' => 'Esta função não pode ser excluída.',
        'delete_own' => 'Você não pode excluir sua função.',

        'discord' => [
            'title' => 'Vincular funções do Discord',
            'enable' => 'Habilitar vínculo de funções do Discord',
            'enable_info' => 'Uma vez habilitado, edite a função no Discord e, na guia <b>Links</b> da função, adicione um requisito. Os usuários podem obter sua função indo no Discord, no menu do servidor e em <b>Funções Vinculadas</b>.',
            'info' => 'Você precisa criar uma aplicação no <a href="https://discord.com/developers/applications" target="_blank">Painel do Desenvolvedor do Discord</a> e definir a <b>URL de Verificação de Funções Vinculadas</b> para <code>:url</code>',
            'oauth' => 'Então, na guia <b>OAuth2</b>, em <b>Geral</b>, você precisa adicionar <code>:url</code> nos <b>Redirecionamentos</b>.',
            'token_info' => 'O token do Bot pode ser obtido criando um bot para sua aplicação, na guia <b>Bot</b> à esquerda do painel do desenvolvedor do Discord.',

            'token' => 'Token do Bot do Discord',
            'client_id' => 'ID do Cliente do Discord',
            'client_secret' => 'Segredo do Cliente do Discord',
        ],
    ],

    'permissions' => [
        'create-comments' => 'Comentar uma postagem',
        'delete-other-comments' => 'Excluir um comentário de postagem de outro usuário',
        'maintenance-access' => 'Acessar o site durante a manutenção',
        'admin-access' => 'Acessar o painel de administração',
        'admin-logs' => 'Visualizar e gerenciar logs do site',
        'admin-images' => 'Visualizar e gerenciar imagens',
        'admin-navbar' => 'Visualizar e gerenciar a barra de navegação',
        'admin-pages' => 'Visualizar e gerenciar páginas',
        'admin-redirects' => 'Visualizar e gerenciar redirecionamentos',
        'admin-posts' => 'Visualizar e gerenciar postagens',
        'admin-roles' => 'Visualizar e gerenciar funções',
        'admin-settings' => 'Visualizar e gerenciar configurações',
        'admin-users' => 'Visualizar e gerenciar usuários',
        'admin-users-personal' => 'Visualizar e gerenciar informações pessoais do usuário',
        'admin-themes' => 'Visualizar e gerenciar temas',
        'admin-plugins' => 'Visualizar e gerenciar plugins',
    ],

    'bans' => [
        'title' => 'Banimentos',

        'by' => 'Banido por',
        'reason' => 'Motivo',
        'removed' => 'Removido em :date por :user',
    ],

    'posts' => [
        'title' => 'Postagens',
        'edit' => 'Editar postagem :post',
        'create' => 'Criar postagem',

        'published_info' => 'Esta postagem não estará visível publicamente até essa data.',
        'pin' => 'Fixar esta postagem',
        'pinned' => 'Fixada',
        'feed' => 'Um feed RSS/Atom para as postagens está disponível em <code>:rss</code> e <code>:atom</code>.',
    ],

    'pages' => [
        'title' => 'Páginas',
        'edit' => 'Editar página #:page',
        'create' => 'Criar página',

        'enable' => 'Habilitar a página',
        'restrict' => 'Limitar funções que poderão acessar esta página',
    ],

    'redirects' => [
        'title' => 'Redirecionamentos',
        'edit' => 'Editando redirecionamento :redirect',
        'create' => 'Criando redirecionamento',

        'enable' => 'Habilitar redirecionamento',
        'source' => 'Origem',
        'destination' => 'Destino',
        'code' => 'Código de status',

        '301' => '301 - Redirecionamento permanente',
        '302' => '302 - Redirecionamento temporário',
    ],

    'images' => [
        'title' => 'Imagens',
        'edit' => 'Editar imagem :image',
        'create' => 'Enviar imagem',
        'help' => 'Se as imagens não estiverem carregando, tente seguir os passos na <a href="https://azuriom.com/docs/faq" target="_blank" rel="noopener norefferer">FAQ</a>.',
    ],

    'extensions' => [
        'buy' => 'Comprar por :price',
        'market' => 'Informações sobre todas as extensões estão disponíveis no <a href=":url" target="_blank" rel="noopener noreferrer">Mercado Azuriom</a>.',
    ],

    'plugins' => [
        'title' => 'Plugins',

        'list' => 'Plugins instalados',
        'available' => 'Plugins disponíveis',

        'requirements' => [
            'api' => 'Esta versão do plugin não é compatível com Azuriom v:version.',
            'azuriom' => 'Este plugin não é compatível com sua versão do Azuriom.',
            'game' => 'Este plugin não é compatível com o jogo :game.',
            'plugin' => 'O plugin ":plugin" está faltando ou sua versão não é compatível com este plugin.',
        ],

        'reloaded' => 'Os plugins foram recarregados.',
        'enabled' => 'O plugin foi ativado.',
        'disabled' => 'O plugin foi desativado.',
        'updated' => 'O plugin foi atualizado.',
        'installed' => 'O plugin foi instalado.',
        'deleted' => 'O plugin foi excluído.',
        'delete_enabled' => 'O plugin deve ser desativado antes que possa ser excluído.',
    ],

    'themes' => [
        'title' => 'Temas',

        'current' => 'Tema atual',
        'author' => 'Autor: :author',
        'version' => 'Versão: :version',
        'list' => 'Temas instalados',
        'available' => 'Temas disponíveis',
        'no-enabled' => 'Você não tem nenhum tema habilitado.',
        'legacy' => 'Esta versão do tema não é compatível com Azuriom v:version.',

        'config' => 'Editar configuração',
        'disable' => 'Desativar tema',

        'reloaded' => 'Os temas foram recarregados.',
        'no_config' => 'Este tema não possui configuração.',
        'config_updated' => 'A configuração do tema foi atualizada.',
        'invalid' => 'Este tema é inválido (o nome da pasta do tema deve ser o id do tema).',
        'updated' => 'O tema foi atualizado.',
        'installed' => 'O tema foi instalado.',
        'deleted' => 'O tema foi excluído.',
        'delete_current' => 'Você não pode excluir o tema atual.',
    ],

    'update' => [
        'title' => 'Atualizar',

        'has_update' => 'Atualização disponível',
        'no_update' => 'Nenhuma atualização disponível',
        'check' => 'Verificar atualizações',

        'update' => 'A versão <code>:last-version</code> do Azuriom está disponível e você está na versão <code>:version</code>.',
        'changelog' => 'O changelog pode ser encontrado no <a href=":url" target="_blank" rel="noopener noreferrer">GitHub</a>.',
        'download' => 'A versão mais recente do Azuriom está pronta para download.',
        'install' => 'A versão mais recente do Azuriom foi baixada e está pronta para ser instalada.',

        'backup' => 'Antes de atualizar o Azuriom, você deve fazer um backup do seu site!',

        'latest_version' => 'Você está executando a versão mais recente do Azuriom: <code>:version</code>.',
        'latest' => 'Você está usando a versão mais recente do Azuriom.',

        'downloaded' => 'A versão mais recente foi baixada; você pode agora instalá‑la.',
        'installed' => 'A atualização foi instalada com sucesso.',

        'php' => 'Você deve usar PHP :version ou superior para atualizar para esta versão do Azuriom.',
    ],

    'logs' => [
        'title' => 'Logs',

        'clear' => 'Limpar logs antigos (15d+)',
        'cleared' => 'Os logs antigos foram excluídos.',
        'changes' => 'Mudanças',
        'old' => 'Valor antigo',
        'new' => 'Novo valor',

        'pages' => [
            'created' => 'Criou a página #:id',
            'updated' => 'Atualizou a página #:id',
            'deleted' => 'Excluiu a página #:id',
        ],

        'posts' => [
            'created' => 'Criou a postagem #:id',
            'updated' => 'Atualizou a postagem #:id',
            'deleted' => 'Excluiu a postagem #:id',
        ],

        'images' => [
            'created' => 'Criou a imagem #:id',
            'updated' => 'Atualizou a imagem #:id',
            'deleted' => 'Excluiu a imagem #:id',
        ],

        'redirects' => [
            'created' => 'Criou o redirecionamento #:id',
            'updated' => 'Atualizou o redirecionamento #:id',
            'deleted' => 'Excluiu o redirecionamento #:id',
        ],

        'roles' => [
            'created' => 'Criou a função #:id',
            'updated' => 'Atualizou a função #:id',
            'deleted' => 'Excluiu a função #:id',
        ],

        'servers' => [
            'created' => 'Criou o servidor #:id',
            'updated' => 'Atualizou o servidor #:id',
            'deleted' => 'Excluiu o servidor #:id',
        ],

        'users' => [
            'updated' => 'Atualizou o usuário #:id',
            'deleted' => 'Excluiu o usuário #:id',
            'transfer' => 'Enviou dinheiro :money para o usuário #:id',

            'login' => 'Login bem‑sucedido de :ip (2FA: :2fa)',
            'api' => [
                'login' => 'Login de API bem‑sucedido de :ip (2FA: :2fa)',
                'verified' => 'Verificação de token de API bem‑sucedida de :ip',
            ],
            '2fa' => [
                'enabled' => 'Ativou a autenticação de dois fatores',
                'disabled' => 'Desativou a autenticação de dois fatores',
            ],
        ],

        'settings' => [
            'updated' => 'Atualizou as configurações',
        ],

        'updates' => [
            'installed' => 'Instalou a atualização do Azuriom',
        ],

        'plugins' => [
            'enabled' => 'Ativou o plugin :plugin',
            'disabled' => 'Desativou o plugin :plugin',
        ],

        'themes' => [
            'changed' => 'Alterou o tema para :theme',
            'configured' => 'Atualizou a configuração do tema :theme',
        ],
    ],

    'errors' => [
        'back' => 'Voltar ao painel',
        '404' => 'Página não encontrada',
        'info' => 'Parece que você encontrou uma falha na matrix...',
        '2fa' => 'Você deve habilitar a autenticação de dois fatores para acessar esta página.',
    ],
];