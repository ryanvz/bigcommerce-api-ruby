BigCommerce API V2 - Ruby Client
================================

This library provides a wrapper around the BigCommerce REST API for use within
Ruby apps or via the console.

Note
----

**The Ruby Client is still in alpha and core features of the API may be
unsupported and undocumented.**

Requirements
------------

- Ruby 1.8.7+
- Rubygems
- JSON

To connect to the API, you need the following credentials:

- Secure URL pointing to a BigCommerce store
- Username of an authorized admin user of the store
- API key for the user

A valid API key is required to authenticate requests. To grant API access for
user, go to Control Panel > Users > Edit User and make sure that the
'Enable the XML API?' checkbox is ticked.

Installation
------------

Download the lib folder and copy it to a path accessible within your app, or
install the package directly from Rubygems:

```
gem install bigcommerce
```

Configuration
-------------

To use the API client in your Ruby code, provide the required credentials as
follows:

```
require 'bigcommerce'

api = BigCommerce::Api.new({
	:store_url => "https://store.mybigcommerce.com",
	:username  => "admin",
	:api_key   => "d81aada4c19c34d913e18f07fd7f36ca"
})
```

Connecting to the store
-----------------------

Ping the get_time method to check that your configuration is working and you
can connect successfully to the store:

```
ping = api.get_time
```

Usage
-----

The API object acts as a gateway to all top level resources in the V2 API.

A list of items can be retrieved using the plural form

```
api.get_products
```

Individual resources can be queried using the singular form with an id as argument

```
api.get_customer(20)
```

Resources can be destoyed (DELETE) through the api object or through the returned resource object

```
> api.destroy_brand(11)
>
> api.get_brand(54).destroy!
```

Updates (PUT) can be also be done in multiple ways

```
> api.update_product(394, :name => 'Best product ever')
>
> api.get_product(382).update(:name => 'Another great product')
>
> product = api.get_product(430)
> product.name = "The best product"
> product.update!
```

Resources can be created by calling create_product, create_customer, etc and passing in a hash of attributes

```
api.create_brand :name => 'Greatbrand'
```

Sub-resources can be accessed through their parent resource.

```
> api.get_customers.first.addresses
>
> api.get_product(243).images
>
```

```
$ irb
>
> api = BigCommerce::Api.new(...)
>
> api.get_products.each { |product| puts product.name }
>
> api.get_customers.each { |customer| puts customer.email }
>
> puts api.get_orders_count
>
> category = api.get_category(11)
> category.name = "Laptops"
> category.update!
>
> brand = api.create_brand :name => "Samsung"
>
> option = api.get_option(22)
> option.destroy!
>
```
