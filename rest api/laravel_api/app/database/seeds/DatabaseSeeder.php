<?php

class DatabaseSeeder extends Seeder {

	/**
	 * Run the database seeds.
	 *
	 * @return void
	 */
	public function run()
	{
		Eloquent::unguard();

		 $this->call('UserTableSeeder');
	}

}

class UserTableSeeder extends Seeder {
    public function run()
    {
        $hashed = Hash::make('secret');

        DB::table('users')->insert(
            array('name'     => 'Neerav Leeroy Machenabadedbi',
                  'email'    => 'neerav@aptosolutions.com',
                  'username' => 'neerav',
                  'password' => $hashed)
            );
    }
}
