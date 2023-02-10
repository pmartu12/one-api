<?php

namespace App\Rest;

use App\Rest\Interface\ResponseHandlerInterface;

class ResponseHandler implements ResponseHandlerInterface
{

    private array $contentTypes = [
        self::FORMAT_JSON => 'application/json',
        self::FORMAT_XML => 'application/xml',
    ];

    /**
     * @param array|string[] $contentTypes
     */
    public function __construct(

        ) {
    }


}
