<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpKernel\Attribute\AsController;

#[AsController]
class HealthzController
{

    public function __construct(

    ) {
    }

    public function __invoke()
    {
    }

}
