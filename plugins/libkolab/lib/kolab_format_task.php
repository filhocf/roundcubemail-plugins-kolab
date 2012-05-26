<?php

/**
 * Kolab Task (ToDo) model class
 *
 * @version @package_version@
 * @author Thomas Bruederli <bruederli@kolabsys.com>
 *
 * Copyright (C) 2012, Kolab Systems AG <contact@kolabsys.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

class kolab_format_task extends kolab_format
{
    public $CTYPE = 'application/calendar+xml';

    protected $read_func = 'kolabformat::readTodo';
    protected $write_func = 'kolabformat::writeTodo';

    private $status_map = array(
        'NEEDS-ACTION' => kolabformat::StatusNeedsAction,
        'IN-PROCESS'   => kolabformat::StatusInProcess,
        'COMPLETED'    => kolabformat::StatusCompleted,
        'CANCELLED'    => kolabformat::StatusCancelled,
    );

    function __construct($xmldata = null)
    {
        $this->obj = new Todo;
        $this->xmldata = $xmldata;
    }

    /**
     * Set properties to the kolabformat object
     *
     * @param array  Object data as hash array
     */
    public function set(&$object)
    {
        $this->init();

        // set some automatic values if missing
        if (!empty($object['uid']))
            $this->obj->setUid($object['uid']);

        // TODO: set object propeties

        // cache this data
        $this->data = $object;
        unset($this->data['_formatobj']);
    }

    /**
     *
     */
    public function is_valid()
    {
        return $this->data || (is_object($this->obj) && $this->obj->isValid());
    }

    /**
     * Load data from old Kolab2 format
     */
    public function fromkolab2($record)
    {
        $object = array(
            'uid'     => $record['uid'],
            'changed' => $record['last-modification-date'],
        );

        // TODO: implement this

        $this->data = $object;
    }

    /**
     * Convert the Configuration object into a hash array data structure
     *
     * @return array  Config object data as hash array
     */
    public function to_array()
    {
        // return cached result
        if (!empty($this->data))
            return $this->data;

        $this->init();

        // read object properties
        $status_map = array_flip($this->status_map);
        $object = array(
            'uid'         => $this->obj->uid(),
            'changed'     => $this->obj->lastModified(),
            'summary'     => $this->obj->summary(),
            'description' => $this->obj->description(),
            'location'    => $this->obj->location(),
            'status'      => $this->status_map[$this->obj->status()],
            'complete'    => intval($this->obj->percentComplete()),
            'priority'    => $this->obj->priority(),
        );

        // if due date is set
        if ($dtstart = $this->obj->start()) {
            $object['start'] = self::php_datetime($dtstart);
        }
        // if due date is set
        if ($due = $this->obj->due()) {
            $object['due'] = self::php_datetime($due);
        }

        // TODO: map more properties

        $this->data = $object;
        return $this->data;
    }

}