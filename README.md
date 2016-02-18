# aggressive-epsilon

Lightweight Rails JSON API for dealing with item reservations.

[![Build Status](https://travis-ci.org/umts/aggressive-epsilon.svg?branch=master)](https://travis-ci.org/umts/aggressive-epsilon)
[![Test Coverage](https://codeclimate.com/github/umts/aggressive-epsilon/badges/coverage.svg)](https://codeclimate.com/github/umts/aggressive-epsilon/coverage)
[![Code Climate](https://codeclimate.com/github/umts/aggressive-epsilon/badges/gpa.svg)](https://codeclimate.com/github/umts/aggressive-epsilon)
[![Issue Count](https://codeclimate.com/github/umts/aggressive-epsilon/badges/issue_count.svg)](https://codeclimate.com/github/umts/aggressive-epsilon)

**This API is currently at version 1. All endpoints listed here are in the format `base_uri/v1/endpoint_uri`.**

## Customer service endpoints

These endpoints are structured so that customer service interfaces need not be concerned with IDs of objects other than reservations.

+ `GET /item_types`

  This endpoint returns a collection of types of items which can be reserved.
  Each item type object has a name, as well as a list of item objects and their names.
  Each item type object also has an `allowed_keys` field, which lists the keys
  which the items' metadata may contain. See `update_item` for details.

  A **response** will look like:

  ```json
    [{"id": 100, "name": "Apples",
      "allowed_keys": ["flavor"],
      "items": [{"name": "Macintosh"},
                {"name": "Granny Smith"}]}]
  ```

  ---

+ `POST /reservations`

   This endpoint accepts the name of an item type, an ISO 8601 start time, and an ISO 8601 end time.

   For instance, your **request** might look like:

   ```json
   POST /reservations
     {"item_type": "Apples",
      "start_time": "2016-02-16T15:30:00-05:00",
      "end_time": "2016-02-17T09:45:00-05:00"}
   ```

   If a reservation with those parameters is available, the attributes of the newly created reservation is returned.
   This ID will be necessary for referencing the reservation later.

   A **success response** will look like:

   ```json
   {"id": 100,
    "start_time": "2016-02-16T15:30:00-05:00",
    "end_time": "2016-02-17T09:45:00-05:00",
    "item_type": "Apples",
    "item": "Granny Smith"}
   ```

   If a reservation is not available, a blank response body is returned with a status of 422 (unprocessable entity).

   ---

+ `PUT /reservations/:id`

   This endpoint allows you to update the start or end times of a reservation.
   If you need a reservation for a different item type, the preferred method is to delete the current reservation
   and to create a new reservation for that item type.

   The start or end times should be in a `reservation` parameter, and should be in ISO 8601 format.

   For instance, your **request** might look like:

   ```json
   PUT /reservations/100
   {"reservation": {"start_time": "2016-02-16T18:00:00-05:00"}}
   ```

   If the change has been successfully applied, a blank response body is returned with a status of 200.
   If there was an error in applying the change, the endpoint will return a list of errors with a status of 422 (unprocessable entity).

   A **failure response** will look like:

   ```json
   {"errors": ["Start time must be before end time"]}
   ```
   ---

+ `GET /reservations/:id`
 
  This endpoint allows you to doublecheck the attributes of any reservation which you have created.

  A **response** will look like:
  ```json
  {"id": 100,
   "start_time": "2016-02-16T15:30:00-05:00",
   "end_time": "2016-02-17T09:45:00-05:00",
   "item_type": "Apples",
   "item": "Granny Smith"}
  ```

  If the requested reservation could not be found, a blank response body is returned with a 404 status.

  ---

+ `DELETE /reservations/:id`

  This endpoint allows you to delete any reservation which you have created.
  If the reservation has been successfully deleted, a blank response body is returned with a status of 200.
  If the reservation could not be found, a 404 will be returned.

  ---

+ `POST /reservations/:id/update_item`

   This endpoint allows you to update any of the metadata belonging to the item reserved in a particular reservation.
   At present, this is a destructive update - the existing metadata will be replaced with the given metadata.
   You can only specify metadata attributes which are in the `allowed_keys` of the item's type.

   The metadata should be in a `data` parameter.

   For instance, your **request** might look like:

   ```json
   POST /reservations/100/update_item
   {"data": {"color": "orange"}}
   ```

   If the change has been successfully applied, a blank response body is returned with a status of 200.
   If there was an error in applying the change, the endpoint will return a list of errors with a status of 422 (unprocessable entity).

   A **failure response** will look like:

   ```json
   {"errors": ["Disallowed key: color"]}
   ```

   ---

+ `GET /reservations`
   
   This endpoint returns all of the reservations for a particular item type in a given time range.
   The `start_time` and `end_time` arguments must be in ISO 8601 format.
   Each reservation will list the start and end times in ISO 8601 format.
   If the requsted item type does not exist, the endpoint will return a blank response body and a 404.

   For instance, your **request** might look like:
   
   ```json
   GET /reservations
   {"start_time": "2016-02-10T12:00:00-05:00",
    "end_time": "2016-02-17T12:00:00-05:00",
    "item_type": "Apples"}
   ```

   A **response** will look like:

   ```json
   [{"start_time": "2016-02-11T15:45:00-05:00", "end_time": "2016-02-11T21:00:00-05:00"},
    {"start_time": "2016-02-17T10:30:00-05:00", "end_time": "2016-02-19T21:00:00-05:00"}]
   ```
   
   ---

## Administration / management endpoints

+ `GET /item_types/:id`
  
  This endpoint lists the properties of an item type and of its items.
  Unlike `/item_types/`, this endpoint lists the ID of each item.

  A **response** will look like:
  ```json
    {"id": 100, "name": "Apples",
     "allowed_keys": ["flavor"],
     "items": [{"id": 400, "name": "Macintosh"},
               {"id": 401, "name": "Granny Smith"}]}
  ```
  
  ---
  
+ `PUT /item_types/:id`

  This endpoint allows you to change the name of an item type.
  Item type changes should be in an `item_type` parameter.
  
  Your **request** might look like:
  ```json
  PUT /item_types/100
  {"item_type": {"name": "Red/Green Fruit"}}
  ```
  
  If the change has been successfully applied, a blank response body is returned with a status of 200.
   If there was an error in applying the change, the endpoint will return a list of errors with a status of 422 (unprocessable entity).

   A **failure response** will look like:

   ```json
   {"errors": ["Name can't be blank"]}
   ```
   
   ---
   
   + `DELETE /item_types/:id`

  This endpoint allows you to delete an item type and its items.
  If the item type has been successfully deleted, a blank response body is returned with a status of 200.
  
  ---
