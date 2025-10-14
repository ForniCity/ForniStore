<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Linhas de idioma de e‑mail
    |--------------------------------------------------------------------------
    |
    | As seguintes linhas de idioma são usadas pela biblioteca de e‑mail para
    | construir o layout dos e‑mails.
    |
    */

    'hello' => 'Olá!',
    'whoops' => 'Ops!',

    'regards' => 'Saudações,',

    'link' => 'Se você está tendo problemas para clicar no botão ":actionText", copie e cole a URL abaixo em seu navegador: [:displayableActionUrl](:actionURL)',

    'copyright' => '&copy; :year :name. Todos os direitos reservados.',

    'test' => [
        'subject' => 'E‑mail de teste em :name',
        'content' => 'Se você pode ver este e‑mail, significa que o envio de e‑mails de :name está funcionando!',
    ],

    'delete' => [
        'subject' => 'Solicitação de exclusão de conta',
        'line1' => 'Você está recebendo este e‑mail porque recebemos uma solicitação de exclusão de sua conta.',
        'action' => 'Excluir minha conta',
        'line2' => 'Esta ação não pode ser desfeita. Isso excluirá permanentemente sua conta e os dados associados. Este link expirará em :count minutos.',
        'line3' => 'Se você não solicitou a exclusão de sua conta, certifique‑se de revisar suas configurações de segurança.',
    ],
];