<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Linhas de idioma de autenticação
    |--------------------------------------------------------------------------
    |
    | As seguintes linhas de idioma são usadas durante a autenticação para
    | diversas mensagens que precisamos exibir ao usuário. Fique à vontade
    | para modificar essas linhas conforme os requisitos da sua aplicação.
    |
    */

    'failed' => 'Estas credenciais não correspondem aos nossos registros.',
    'throttle' => 'Muitas tentativas de login. Por favor, tente novamente em :seconds segundos.',

    'register' => 'Registrar',
    'login' => 'Entrar',
    'logout' => 'Sair',
    'verify' => 'Verifique seu endereço de e‑mail',
    'passwords' => [
        'confirm' => 'Confirmar senha',
        'reset' => 'Redefinir senha',
        'send' => 'Enviar link de redefinição de senha',
    ],
    'fpc' => [
        'title' => 'Alteração de senha obrigatória',
        'line1' => 'Sua conta foi temporariamente bloqueada por motivos de segurança. Para desbloqueá‑la, altere sua senha.',
        'line2' => 'Se você precisar de mais informações ou tiver problemas para desbloquear sua conta, entre em contato com o administrador do site.',
        'action' => 'Alterar minha senha',
    ],
    'name' => 'Nome de usuário',
    'email' => 'Endereço de e‑mail',
    'password' => 'Senha',
    'confirm_password' => 'Confirmar senha',
    'current_password' => 'Senha atual',

    'conditions' => 'Eu aceito as <a href=":url" target="_blank">condições</a>.',

    '2fa' => [
        'code' => 'Código de autenticação de dois fatores',
        'invalid' => 'Código inválido',
    ],

    'suspended' => 'Esta conta está suspensa.',

    'maintenance' => 'O site está em manutenção.',

    'remember' => 'Lembrar‑me',
    'forgot_password' => 'Esqueceu sua senha?',

    'verification' => [
        'sent' => 'Um novo link de verificação foi enviado para seu endereço de e‑mail.',
        'check' => 'Antes de prosseguir, verifique seu e‑mail para ver o link de verificação.',
        'request' => 'Se você não recebeu o e‑mail, pode solicitar outro.',
        'resend' => 'Reenviar e‑mail',
    ],

    'confirmation' => 'Por favor, confirme sua senha antes de continuar.',

    'mail' => [
        'reset' => [
            'subject' => 'Notificação de redefinição de senha',
            'line1' => 'Você está recebendo este e‑mail porque recebemos uma solicitação de redefinição de senha para sua conta.',
            'action' => 'Redefinir senha',
            'line2' => 'Este link de redefinição de senha irá expirar em :count minutos.',
            'line3' => 'Se você não solicitou uma redefinição de senha, nenhuma outra ação é necessária.',
        ],

        'verify' => [
            'subject' => 'Verificar endereço de e‑mail',
            'line1' => 'Clique no botão abaixo para verificar seu endereço de e‑mail. Este link é válido por :count minutos.',
            'action' => 'Verificar endereço de e‑mail',
            'line2' => 'Se você não criou uma conta, nenhuma outra ação é necessária.',
        ],
    ],
];