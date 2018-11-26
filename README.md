# Rails survey calculator.

This is a source code of API and Ruby workers, described in article [Comparing the performance of RoR and Go applications in background processing](https://medium.com/@alexander.potrakhov/comparing-the-performance-of-ror-and-go-applications-in-computation-heavy-tasks-85140bda1e6b).

The application needs [Postgres 9.6.3](https://www.postgresql.org/docs/9.6/tutorial-install.html) and [Redis](https://redis.io/download) to run. Also, it requires postgresql-dev package installed.

## Steps to run
1) Get [rvm](https://rvm.io/)
2) Install ruby 2.5.1
3) Run *bundle*
4) Create and fill in the .env.development file. The necessary keys are listed in .env
5) Run *rails:db:setup*
6) Run *rails:db:populate_survey_results* to generate samples
7) Run *rails server*
8) Run *sidekiq* in a separate terminal tab
9) Setup [go worker](https://github.com/a11ejandro/golang_survey_calculator)
10) (Optional) setup [Web-ui](https://github.com/a11ejandro/survey_ui)
