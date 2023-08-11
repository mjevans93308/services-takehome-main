import falcon
import json
import datetime
import logging

logger = logging.getLogger('subscription_logger')
logger.setLevel(logging.DEBUG)
formatter = logging.Formatter('[%(asctime)s] [%(name)s] [%(levelname)s] %(message)s')
stream_handler = logging.StreamHandler()
stream_handler.setFormatter(formatter)
logger.addHandler(stream_handler)

def get_subscription(user_id):
        subscription_data = [
            {
                "user_id": 1,
                "renewal_date": (datetime.date.today() + datetime.timedelta(days=30)).strftime("%m/%d/%Y"),
                "price_cents": 1500,
                "plan": "monthly",
            }, {
                "user_id": 2,
                "renewal_date": (datetime.date.today() + datetime.timedelta(days=60)).strftime("%m/%d/%Y"),
                "price_cents": 3000,
                "plan": "monthly"
            }, {
                "user_id": 3,
                "renewal_date": (datetime.date.today() + datetime.timedelta(days=90)).strftime("%m/%d/%Y"),
                "price_cents": 14500,
                "plan": "yearly"
            }, {
                "user_id": 4,
                "renewal_date": (datetime.date.today() + datetime.timedelta(days=120)).strftime("%m/%d/%Y"),
                "price_cents": 16000,
                "plan": "yearly"
            }, {
                "user_id": 5,
                "renewal_date": (datetime.date.today() + datetime.timedelta(days=150)).strftime("%m/%d/%Y"),
                "price_cents": 17500,
                "plan": "yearly"
            }
        ]

        for sub in subscription_data:
             if sub["user_id"] == user_id:
                  return sub
             
        return None


class SubscriptionResource:
    def on_get(self, request, response):
        user_id = int(request.get_param('user_id'))

        subscription =  get_subscription(user_id)

        response.content_type = falcon.MEDIA_JSON

        if not subscription:
            logger.debug("Subscription not found")
            response.status = falcon.HTTP_NOT_FOUND
            response.body = json.dumps({"message": f"No subscription found for user_id [{user_id}]"})
        else:
            logger.debug(f"Subscription found: {subscription}")
            response.status = falcon.HTTP_OK
            del subscription["plan"]
            response.body = json.dumps(subscription)


app = falcon.App()
app.add_route('/subscriptions', SubscriptionResource())