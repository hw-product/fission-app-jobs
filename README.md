# Fission App Jobs

Application jobs that can be "backgrounded".

## Goal

To implement background-able jobs in such a manner
as to be easily ran in the foreground or background.
This means common approach to running an action and
simple wrapper to allow running within fission or
being called directly from the app.

## Implementation

Subclass `Fission::App::Jobs::Utils` and implement `run!`
method.