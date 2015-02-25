<?php

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It's a breeze. Simply tell Laravel the URIs it should respond to
| and give it the Closure to execute when that URI is requested.
|
*/

Route::get('/', function()
{
	return View::make('hello');
});

Route::get('words', 'WordController@index');
Route::get('words/{entry}', 'WordController@show');
Route::match(['put', 'post'], 'words/{entry?}', 'WordController@put');
#Route::put('words/{entry?}', 'WordController@put');
#Route::post('words/{entry?}', 'WordController@put');

#Route::resource('words', 'WordController');

Route::resource('users', 'users');
