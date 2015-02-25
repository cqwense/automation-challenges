<?php

class WordController extends \BaseController {

	/**
	 * Display a listing of the resource.
	 *
	 * @return Response
	 */
	public function index()
	{
	    $search = Word::all()->toArray();
        
        $words = array();
        foreach($search as $found)
        {
            $words[$found['word']] = $found['count'];
        }

        return json_encode($words);

        /* More complete output - but not what client wants
           - Note: explain value of all of nothing.

        return Response::json(array(
            'error' => false,
            'words' => $words->toArray()),
            200
        );
        */
    }

# Ok - so the request called for the JSON to be included in the body
# of the HTML ( opposed to $_REQUEST which I have a sneaky suspission 
# will be part of my on-site interview )- so the route file looks 
# for specific PUT requests and grabs the data from BODY via URLEncoding
# and/or a hidden '_metho' = 'PUT' defined in an HTML form.

    # client says put requests mean "word" is in body via JSON:
    public function put()
    {
        $data = Input::json()->all();
    
        #laravel has validation tools - I don't know them yet.
        if(isset($data['word'])  && 
           !empty($data['word']) && 
           str_word_count($data['word']) == 1 &&
           !is_int($data['word']))
        {

            $id = $this->searchFor($data['word']);

            if($id)
                return $this->show($this->store($id));
            else
                return $this->show($this->create($data['word']));
        }
        else
        {
            return Response::json(array(
                'error' => 'PUT requests must be one word in length'));
        }

    }

    # clean this up later - lil redundant, but for now its already above and
    # beyond - but this takes care of POST data
    public function post()
    {
        $data = Input::all();

        if(isset($data['word'])  && 
           !empty($data['word']) && 
           str_word_count($data['word']) == 1 &&
           !is_int($data['word']))
        {

            $id = $this->searchFor($data['word']);

            if($id)
                return $this->show($this->store($id));
            else
                return $this->show($this->create($data['word']));
        }
        else
        {
            return Response::json(array(
                'error' => 'POST requests must be one word in length'));
        }

    }
    public function searchFor($check)
    {
        $word =  Word::where('word', '=', $check)->first();
        $id = null;

        if($word)
        {
            $return = $word->toArray();
            return $return['id'];
        }
        else return 0;
    }
        

	/**
	 * Show the form for creating a new resource.
	 *
	 * @return Response
	 */
	public function create($entry)
	{
        $word = new Word;
        $word->word = $entry;
        $word->count = 1;

        $word->save();

        return $word->id;
		//
	}


	/**
	 * Store a newly created resource in storage.
	 *
	 * @return Response
	 */
	public function store($id)
	{
		
        $word = Word::find($id);
        $word->count = $word->count + 1;
        $word->save();
        
        return $word->id;
	}


	/**
	 * Display the specified resource.
	 *
	 * @param  int  $id
	 * @return Response
	 */
	public function show($id = null)
	{
        if(!is_int($id))
        {
            $id = $this->searchFor($id);
        }

        $word = Word::find($id);
        $json = array();

        if($word)
        {
            $word = $word->toArray();
            $json[$word['word']] = $word['count'];

            return json_encode($json);

            /* Seen line 22 
            return Response::json(array(
                'error' => false,
                'word' => $word->toArray()),
                200
            );
            */
	    }
        else
        {
            return ;
        }
    }


	/**
	 * Show the form for editing the specified resource.
	 *
	 * @param  int  $id
	 * @return Response
	 */
	public function edit($id)
	{
		//
	}


	/**
	 * Update the specified resource in storage.
	 *
	 * @param  int  $id
	 * @return Response
	 */
	public function update($id)
	{
	
    }


	/**
	 * Remove the specified resource from storage.
	 *
	 * @param  int  $id
	 * @return Response
	 */
	public function destroy($id)
	{
		//
	}


}
