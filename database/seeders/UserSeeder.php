<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Vendor;
use App\Models\Reseller;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Admin
        $admin = User::create([
            'name' => 'Admin Funtasting',
            'email' => 'admin@funtasting.it',
            'password' => Hash::make('password'),
            'role' => 'admin',
        ]);

        // Vendor 1
        $vendor1 = User::create([
            'name' => 'Guida Turistica Le Marche',
            'email' => 'vendor1@funtasting.it',
            'password' => Hash::make('password'),
            'role' => 'vendor',
            'phone' => '+39 333 1234567',
            'city' => 'Ancona',
        ]);

        Vendor::create([
            'user_id' => $vendor1->id,
            'company_name' => 'Guida Turistica Le Marche',
            'email' => $vendor1->email,
            'about_us' => 'Esperienza decennale nella guida turistica delle Marche. Specializzati in tour culturali e naturalistici.',
            'rating' => 4.8,
            'kyc_status' => 'approved',
        ]);

        // Vendor 2
        $vendor2 = User::create([
            'name' => 'Adventure Sport Marche',
            'email' => 'vendor2@funtasting.it',
            'password' => Hash::make('password'),
            'role' => 'vendor',
            'phone' => '+39 333 7654321',
            'city' => 'Ascoli Piceno',
        ]);

        Vendor::create([
            'user_id' => $vendor2->id,
            'company_name' => 'Adventure Sport Marche',
            'email' => $vendor2->email,
            'about_us' => 'Organizziamo attività sportive e avventurose nelle Marche: speleologia, canyoning, trekking.',
            'rating' => 4.9,
            'kyc_status' => 'approved',
        ]);

        // Reseller (Hotel)
        $reseller1 = User::create([
            'name' => 'Hotel Riviera',
            'email' => 'reseller1@funtasting.it',
            'password' => Hash::make('password'),
            'role' => 'reseller',
            'phone' => '+39 071 123456',
            'city' => 'Ancona',
        ]);

        Reseller::create([
            'user_id' => $reseller1->id,
            'company_name' => 'Hotel Riviera',
            'business_type' => 'hotel',
            'email' => $reseller1->email,
            'address' => 'Via della Riviera, 1 - Ancona',
        ]);

        // Customer
        $customer = User::create([
            'name' => 'Mario Rossi',
            'email' => 'customer@funtasting.it',
            'password' => Hash::make('password'),
            'role' => 'customer',
            'phone' => '+39 333 9998888',
            'city' => 'Roma',
        ]);

        $this->command->info('Utenti creati:');
        $this->command->info('- Admin: admin@funtasting.it / password');
        $this->command->info('- Vendor 1: vendor1@funtasting.it / password');
        $this->command->info('- Vendor 2: vendor2@funtasting.it / password');
        $this->command->info('- Reseller: reseller1@funtasting.it / password');
        $this->command->info('- Customer: customer@funtasting.it / password');
    }
}
