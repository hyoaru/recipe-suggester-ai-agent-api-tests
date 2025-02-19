import logging
from dotenv import load_dotenv

logging.basicConfig(
    level=logging.INFO, format="[%(asctime)s] - [%(levelname)s] - %(message)s"
)

logging.info("Loading environment variables...")
load_dotenv()
logging.info("Environment variables loaded.")
