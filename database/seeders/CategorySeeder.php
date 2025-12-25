<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categories = [
            [
                'name' => 'Arte e Cultura',
                'slug' => 'arte-e-cultura',
                'description' => 'Musei, gallerie, monumenti e tour culturali',
                'icon' => 'palette',
                'tags' => ['cultura', 'storia', 'arte'],
                'order' => 1,
            ],
            [
                'name' => 'Sport e Avventura',
                'slug' => 'sport-e-avventura',
                'description' => 'Attività sportive e avventurose all\'aperto',
                'icon' => 'mountain',
                'tags' => ['adrenalina', 'sport', 'avventura'],
                'order' => 2,
            ],
            [
                'name' => 'Mare e Laghi',
                'slug' => 'mare-e-laghi',
                'description' => 'Esperienze acquatiche e costiere',
                'icon' => 'water',
                'tags' => ['relax', 'natura', 'mare'],
                'order' => 3,
            ],
            [
                'name' => 'Natura',
                'slug' => 'natura',
                'description' => 'Escursioni, trekking e attività naturalistiche',
                'icon' => 'tree',
                'tags' => ['natura', 'relax', 'benessere'],
                'order' => 4,
            ],
            [
                'name' => 'Enogastronomia',
                'slug' => 'enogastronomia',
                'description' => 'Degustazioni, tour enogastronomici e corsi di cucina',
                'icon' => 'wine',
                'tags' => ['gusto', 'tradizione', 'relax'],
                'order' => 5,
            ],
            [
                'name' => 'Benessere',
                'slug' => 'benessere',
                'description' => 'Spa, terme, yoga e attività di benessere',
                'icon' => 'spa',
                'tags' => ['relax', 'benessere', 'salute'],
                'order' => 6,
            ],
            [
                'name' => 'Storia',
                'slug' => 'storia',
                'description' => 'Tour storici, borghi antichi e siti archeologici',
                'icon' => 'book',
                'tags' => ['cultura', 'storia', 'tradizione'],
                'order' => 7,
            ],
            [
                'name' => 'Architettura',
                'slug' => 'architettura',
                'description' => 'Tour architettonici e visite a palazzi storici',
                'icon' => 'building',
                'tags' => ['cultura', 'arte', 'storia'],
                'order' => 8,
            ],
            [
                'name' => 'Motorbike',
                'slug' => 'motorbike',
                'description' => 'Tour in moto e esperienze su due ruote',
                'icon' => 'bike',
                'tags' => ['adrenalina', 'sport', 'libertà'],
                'order' => 9,
            ],
            [
                'name' => 'Bike',
                'slug' => 'bike',
                'description' => 'Ciclismo, mountain bike e tour in bicicletta',
                'icon' => 'bicycle',
                'tags' => ['sport', 'natura', 'salute'],
                'order' => 10,
            ],
        ];

        foreach ($categories as $category) {
            Category::create($category);
        }
    }
}
