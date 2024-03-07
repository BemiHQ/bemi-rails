<div align="center">
  <a href="https://bemi.io">
    <img width="1201" alt="bemi-banner" src="https://docs.bemi.io/img/bemi-banner.png">
  </a>

  <p align="center">
    <a href="https://bemi.io">Website</a>
    ·
    <a href="https://docs.bemi.io">Docs</a>
    ·
    <a href="https://github.com/BemiHQ/bemi-rails-example">Example</a>
    ·
    <a href="https://github.com/BemiHQ/bemi-rails/issues/new">Report Bug</a>
    ·
    <a href="https://github.com/BemiHQ/bemi-rails/issues/new">Request Feature</a>
    ·
    <a href="https://discord.gg/mXeZ6w2tGf">Discord</a>
    ·
    <a href="https://twitter.com/BemiHQ">Twitter</a>
    ·
    <a href="https://www.linkedin.com/company/bemihq/about">LinkedIn</a>
  </p>
</div>

# Bemi Rails

[Bemi](https://bemi.io) plugs into [Ruby on Rails](https://github.com/rails/rails) with Active Record and PostgreSQL to track database changes automatically. It unlocks robust context-aware audit trails and time travel querying inside your application.

Designed with simplicity and non-invasiveness in mind, Bemi doesn't require any alterations to your existing database structure. It operates in the background, empowering you with data change tracking features.

This Ruby gem is a recommended Ruby on Rails integration, enabling you to pass application-specific context when performing database changes. This can include context such as the 'where' (API endpoint, worker, etc.), 'who' (user, cron job, etc.), and 'how' behind a change, thereby enriching the information captured by Bemi.

## Contents

- [Highlights](#highlights)
- [Use cases](#use-cases)
- [Quickstart](#quickstart)
- [Architecture overview](#architecture-overview)
- [Alternatives](#alternatives)
- [License](#license)

## Highlights

- Automatic and secure database change tracking with application-specific context in a structured form
- 100% reliability in capturing data changes, even if executed through direct SQL outside the application
- High performance without affecting code runtime execution and database workload
- Easy-to-use without changing table structures and rewriting the code
- Time travel querying and ability to easily group and filter changes
- Scalability with an automatically provisioned cloud infrastructure
- Full ownership of your data

See [an example repo](https://github.com/BemiHQ/bemi-rails-example) for a Ruby on Rails app that automatically tracks all changes.

## Use cases

There's a wide range of use cases that Bemi is built for! The tech was initially built as a compliance engineering system for fintech that supported $15B worth of assets under management, but has since been extracted into a general-purpose utility. Some use cases include:

- **Audit Trails:** Use logs for compliance purposes or surface them to customer support and external customers.
- **Change Reversion:** Revert changes made by a user or rollback all data changes within an API request.
- **Time Travel:** Retrieve historical data without implementing event sourcing.
- **Troubleshooting:** Identify the root cause of application issues.
- **Distributed Tracing:** Track changes across distributed systems.
- **Testing:** Rollback or roll-forward to different application test states.
- **Analyzing Trends:** Gain insights into historical trends and changes for informed decision-making.

## Quickstart

Install the gem by adding it to your `Gemfile`

```
gem 'bemi-rails'
```

Specify custom application context that will be automatically passed with all data changes

```rb
class ApplicationController < ActionController::Base
  before_action :set_bemi_context

  private

  def set_bemi_context
    Bemi.set_context(
      user_id: current_user&.id,
      endpoint: "#{request.method} #{request.path}",
      method: "#{self.class}##{action_name}",
    )
  end
end
```

Make database changes and make sure they're all stored in a table called `changes` in the destination DB

```
psql -h [HOSTNAME] -U [USERNAME] -d [DATABASE] -c 'SELECT "primary_key", "table", "operation", "before", "after", "context", "committed_at" FROM changes;'

 primary_key | table  | operation |                       before                    |                       after                      |                                context                                                   |      committed_at
-------------+--------+-----------+-------------------------------------------------+--------------------------------------------------+------------------------------------------------------------------------------------------+------------------------
 26          | todos  | CREATE    | {}                                              | {"id": 26, "task": "Sleep", "completed": false}  | {"user_id": 187234, "endpoint": "POST /todos", "method": "TodosController#create"}       | 2023-12-11 17:09:09+00
 27          | todos  | CREATE    | {}                                              | {"id": 27, "task": "Eat", "completed": false}    | {"user_id": 187234, "endpoint": "POST /todos", "method": "TodosController#create"}       | 2023-12-11 17:09:11+00
 28          | todos  | CREATE    | {}                                              | {"id": 28, "task": "Repeat", "completed": false} | {"user_id": 187234, "endpoint": "POST /todos", "method": "TodosController#create"}       | 2023-12-11 17:09:13+00
 26          | todos  | UPDATE    | {"id": 26, "task": "Sleep", "completed": false} | {"id": 26, "task": "Sleep", "completed": true}   | {"user_id": 187234, "endpoint": "POST /todos/26", "method": "TodosController#update"}    | 2023-12-11 17:09:15+00
 27          | todos  | DELETE    | {"id": 27, "task": "Eat", "completed": false}   | {}                                               | {"user_id": 187234, "endpoint": "DELETE /todos/27", "method": "TodosController#destroy"} | 2023-12-11 17:09:18+00
```

Check out our [docs](https://docs.bemi.io/orms/rails) for more details.

## Architecture overview

Bemi is designed to be lightweight and secure. It takes a practical approach to achieving the benefits of [event sourcing](https://martinfowler.com/eaaDev/EventSourcing.html) without requiring rearchitecting existing code, switching to highly specialized databases, or using unnecessary git-like abstractions on top of databases. We want your system to work the way it already does with your existing database to allow keeping things as simple as possible.

Bemi plugs into both the database and application levels, ensuring 100% reliability and a comprehensive understanding of every change.

On the database level, Bemi securely connects to PostgreSQL's [Write-Ahead Log](https://www.postgresql.org/docs/current/wal-intro.html) and implements [Change Data Capture](https://en.wikipedia.org/wiki/Change_data_capture). This allows tracking even the changes that get triggered via direct SQL.

On the application level, this gem automatically passes application context to the replication logs to enhance the low-level database changes. For example, information about a user who made a change, an API endpoint where the change was triggered, a worker name that automatically triggered database changes, etc.

Bemi workers then stitch the low-level data with the application context and store this information in a structured easily queryable format, as depicted below:

![bemi-architechture](https://docs.bemi.io/img/architecture.png)

The cloud solution includes worker ingesters, queues for fault tolerance, and an automatically scalable cloud-hosted PostgreSQL. Bemi currently doesn't support a self hosted option, but [contact us](mailto:hi@bemi.io) if this is required.

## Alternatives

|                            | [Bemi](https://github.com/BemiHQ/bemi-rails)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | [PaperTrail](https://github.com/paper-trail-gem/paper_trail) | [Audited](https://github.com/collectiveidea/audited)&nbsp;&nbsp;&nbsp;&nbsp; | [Logidze](https://github.com/palkan/logidze)&nbsp;&nbsp;&nbsp;&nbsp; |
|----------------------------|------|------|------|------|
| Open source                | ✅   | ✅   | ✅   | ✅   |
| Capturing record deletions | ✅   | ✅   | ✅   | ❌   |
| Reliability and accuracy   | ✅   | ❌   | ❌   | ❌   |
| Scalability                | ✅   | ❌   | ❌   | ❌   |
| No performance impact      | ✅   | ❌   | ❌   | ❌   |
| Easy-to-use UI             | ✅   | ❌   | ❌   | ❌   |

## License

Distributed under the terms of the [LGPL-3.0 License](LICENSE).
If you need to modify and distribute the code, please release it to contribute back to the open-source community.
