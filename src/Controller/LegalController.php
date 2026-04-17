<?php

declare(strict_types=1);

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

/**
 * Controller für rechtliche Seiten (Impressum, Datenschutz).
 */
class LegalController extends AbstractController
{
    #[Route('/impressum', name: 'impressum', methods: ['GET'])]
    public function impressum(): Response
    {
        return $this->render('legal/impressum.html.twig');
    }

    #[Route('/datenschutz', name: 'datenschutz', methods: ['GET'])]
    public function datenschutz(): Response
    {
        return $this->render('legal/datenschutz.html.twig');
    }
}
